from operator import attrgetter

from django import forms
import io
import json
import zipfile
from django.contrib import admin
from django.core.exceptions import PermissionDenied
from django.db import transaction
from django.forms import ModelForm
from django.urls import reverse, reverse_lazy
from django.utils import timezone
from django.utils.html import format_html
from django.utils.translation import gettext, gettext_lazy as _, ngettext
from reversion.admin import VersionAdmin

from judge.models import LanguageLimit, Problem, ProblemClarification, ProblemPointsVote, ProblemTranslation, Profile, \
    Solution, ProblemGroup, ProblemType
import uuid
import logging
from judge.events.publishers import package_event as package_event_publisher
from judge.models.runtime import Language
from judge.utils.views import NoBatchDeleteMixin
from judge.widgets import AdminHeavySelect2MultipleWidget, AdminMartorWidget, AdminSelect2MultipleWidget, \
    AdminSelect2Widget, CheckboxSelectMultipleWithSelectAll


class ProblemForm(ModelForm):
    change_message = forms.CharField(max_length=256, label=_('Edit reason'), required=False)
    # Allow uploading a problem package (zip). If provided, we will try to read config.json
    # and use it to fill identification fields. The presence of a package will also relax
    # validation for a number of normally-required fields in the admin form.
    problem_package = forms.FileField(label=_('Problem package'), required=False,
                                      help_text=_('Upload a ZIP problem package (config.json at root).'))

    def __init__(self, *args, **kwargs):
        super(ProblemForm, self).__init__(*args, **kwargs)
        self.fields['authors'].widget.can_add_related = False
        self.fields['curators'].widget.can_add_related = False
        self.fields['testers'].widget.can_add_related = False
        self.fields['banned_users'].widget.can_add_related = False
        self.fields['change_message'].widget.attrs.update({
            'placeholder': gettext('Describe the changes you made (optional)'),
        })
        # Allow admin to submit without filling all required fields — server-side
        # defaults will be applied in save_model(). This makes creating a problem
        # quick and avoids client-side validation blocking when defaults are desired.
        for fld in ('types', 'group', 'time_limit', 'memory_limit', 'allowed_languages', 'points',
                    'code', 'name', 'description'):
            if fld in self.fields:
                self.fields[fld].required = False

        # If the problem already has an attached package, show its name and
        # a download link in the help text for the upload field.
        try:
            if getattr(self, 'instance', None) and getattr(self.instance, 'pk', None):
                from judge.models import ProblemData
                pdata = ProblemData.objects.filter(problem=self.instance).first()
                if pdata:
                    pkg_name = None
                    pkg_url = None
                    if getattr(pdata, 'package_path', None):
                        pkg_name = pdata.package_path.split('/')[-1]
                    elif getattr(pdata, 'zipfile', None):
                        try:
                            pkg_name = pdata.zipfile.name.split('/')[-1]
                        except Exception:
                            pkg_name = None
                    try:
                        pkg_url = reverse('problem_package_download', args=[self.instance.code])
                    except Exception:
                        pkg_url = None

                    if pkg_name:
                        if pkg_url:
                            extra = format_html(' Currently: <a href="{0}">{1}</a>', pkg_url, pkg_name)
                        else:
                            extra = format_html(' Currently: {0}', pkg_name)
                        self.fields['problem_package'].help_text = (self.fields['problem_package'].help_text + extra)
        except Exception:
            # Do not let help-text rendering failures break the admin form.
            pass

    class Meta:
        widgets = {
            'authors': AdminHeavySelect2MultipleWidget(data_view='profile_select2'),
            'curators': AdminHeavySelect2MultipleWidget(data_view='profile_select2'),
            'testers': AdminHeavySelect2MultipleWidget(data_view='profile_select2'),
            'banned_users': AdminHeavySelect2MultipleWidget(data_view='profile_select2'),
            'organizations': AdminHeavySelect2MultipleWidget(data_view='organization_select2'),
            'types': AdminSelect2MultipleWidget,
            'group': AdminSelect2Widget,
            'description': AdminMartorWidget(attrs={'data-markdownfy-url': reverse_lazy('problem_preview')}),
        }

    def clean(self):
        cleaned = super(ProblemForm, self).clean()
        pkg = cleaned.get('problem_package') or self.files.get('problem_package')
        if not pkg:
            return cleaned

        # If a package is uploaded, attempt to extract config.json and pre-fill
        # identification fields (code/name/description). If config.json is not present
        # we don't block saving here, but we will relax form validation for several
        # fields so the admin can continue and the save handler will attempt sensible
        # defaults.
        try:
            data = pkg.read()
            z = zipfile.ZipFile(io.BytesIO(data))
            # config.json at root expected by problem package spec
            try:
                with z.open('config.json') as cj:
                    cfg = json.load(cj)
            except KeyError:
                # try .judge/config.json as a fallback
                try:
                    with z.open('.judge/config.json') as cj:
                        cfg = json.load(cj)
                except KeyError:
                    cfg = {}
        except Exception:
            cfg = {}

        # Map known fields from package config to form fields when present
        pid = cfg.get('problem_id') or cfg.get('problemID')
        pname = cfg.get('problem_name') or cfg.get('problemName') or cfg.get('problem')
        pdesc = cfg.get('description')

        if pid and 'code' in self.fields and not cleaned.get('code'):
            # sanitize to allowed characters in Problem.code: keep lowercase alnum
            s = ''.join(ch for ch in pid.lower() if ch.isalnum())
            cleaned['code'] = s
            self.data = self.data.copy()
            self.data['code'] = s

        if pname and 'name' in self.fields and not cleaned.get('name'):
            cleaned['name'] = pname
            self.data = self.data.copy()
            self.data['name'] = pname

        if pdesc and 'description' in self.fields and not cleaned.get('description'):
            cleaned['description'] = pdesc
            self.data = self.data.copy()
            self.data['description'] = pdesc

        # Relax a number of normally-required fields in the admin form so the
        # admin user can rely on the package to provide runtime/test configuration.
        for fld in ('types', 'group', 'time_limit', 'memory_limit', 'allowed_languages', 'points'):
            if fld in self.fields:
                self.fields[fld].required = False

        return cleaned


class ProblemCreatorListFilter(admin.SimpleListFilter):
    title = parameter_name = 'creator'

    def lookups(self, request, model_admin):
        queryset = Profile.objects.exclude(authored_problems=None).values_list('user__username', flat=True)
        return [(name, name) for name in queryset]

    def queryset(self, request, queryset):
        if self.value() is None:
            return queryset
        return queryset.filter(authors__user__username=self.value())


class LanguageLimitInlineForm(ModelForm):
    class Meta:
        widgets = {'language': AdminSelect2Widget}


class LanguageLimitInline(admin.TabularInline):
    model = LanguageLimit
    fields = ('language', 'time_limit', 'memory_limit')
    form = LanguageLimitInlineForm


class ProblemClarificationForm(ModelForm):
    class Meta:
        widgets = {'description': AdminMartorWidget(attrs={'data-markdownfy-url': reverse_lazy('comment_preview')})}


class ProblemClarificationInline(admin.StackedInline):
    model = ProblemClarification
    fields = ('description',)
    form = ProblemClarificationForm
    extra = 0


class ProblemSolutionForm(ModelForm):
    def __init__(self, *args, **kwargs):
        super(ProblemSolutionForm, self).__init__(*args, **kwargs)
        self.fields['authors'].widget.can_add_related = False

    class Meta:
        widgets = {
            'authors': AdminHeavySelect2MultipleWidget(data_view='profile_select2'),
            'content': AdminMartorWidget(attrs={'data-markdownfy-url': reverse_lazy('solution_preview')}),
        }


class ProblemSolutionInline(admin.StackedInline):
    model = Solution
    fields = ('is_public', 'publish_on', 'authors', 'content')
    form = ProblemSolutionForm
    extra = 0


class ProblemTranslationForm(ModelForm):
    class Meta:
        widgets = {'description': AdminMartorWidget(attrs={'data-markdownfy-url': reverse_lazy('problem_preview')})}


class ProblemTranslationInline(admin.StackedInline):
    model = ProblemTranslation
    fields = ('language', 'name', 'description')
    form = ProblemTranslationForm
    extra = 0

    def has_permission_full_markup(self, request, obj=None):
        if not obj:
            return True
        return request.user.has_perm('judge.problem_full_markup') or not obj.is_full_markup

    has_add_permission = has_change_permission = has_delete_permission = has_permission_full_markup


class ProblemAdmin(NoBatchDeleteMixin, VersionAdmin):
    fieldsets = (
        (None, {
            'fields': (
                'code', 'name', 'problem_package', 'is_public', 'is_manually_managed', 'date', 'authors', 'curators', 'testers',
                'organizations', 'submission_source_visibility_mode', 'is_full_markup',
                'description', 'license',
            ),
        }),
        (_('Social Media'), {'classes': ('collapse',), 'fields': ('og_image', 'summary')}),
        (_('Taxonomy'), {'fields': ('types', 'group')}),
        (_('Points'), {'fields': (('points', 'partial'), 'short_circuit')}),
        (_('Limits'), {'fields': ('time_limit', 'memory_limit')}),
        (_('Language'), {'fields': ('allowed_languages',)}),
        (_('Justice'), {'fields': ('banned_users',)}),
        (_('History'), {'fields': ('change_message',)}),
    )
    list_display = ['code', 'name', 'show_authors', 'points', 'is_public', 'show_public']
    ordering = ['code']
    search_fields = ('code', 'name', 'authors__user__username', 'curators__user__username')
    inlines = [LanguageLimitInline, ProblemClarificationInline, ProblemSolutionInline, ProblemTranslationInline]
    list_max_show_all = 1000
    actions_on_top = True
    actions_on_bottom = True
    list_filter = ('is_public', ProblemCreatorListFilter)
    form = ProblemForm
    date_hierarchy = 'date'

    def get_actions(self, request):
        actions = super(ProblemAdmin, self).get_actions(request)

        if request.user.has_perm('judge.change_public_visibility') or \
                request.user.has_perm('judge.create_private_problem'):
            func, name, desc = self.get_action('make_public')
            actions[name] = (func, name, desc)

            func, name, desc = self.get_action('make_private')
            actions[name] = (func, name, desc)

        func, name, desc = self.get_action('update_publish_date')
        actions[name] = (func, name, desc)

        return actions

    def get_readonly_fields(self, request, obj=None):
        fields = self.readonly_fields
        if not request.user.has_perm('judge.create_private_problem'):
            fields += ('organizations',)
            if not request.user.has_perm('judge.change_public_visibility'):
                fields += ('is_public',)
        if not request.user.has_perm('judge.change_manually_managed'):
            fields += ('is_manually_managed',)
        if not request.user.has_perm('judge.problem_full_markup'):
            fields += ('is_full_markup',)
            if obj and obj.is_full_markup:
                fields += ('description',)
        return fields

    @admin.display(description=_('authors'))
    def show_authors(self, obj):
        return ', '.join(map(attrgetter('user.username'), obj.authors.all()))

    @admin.display(description='')
    def show_public(self, obj):
        return format_html('<a href="{1}">{0}</a>', gettext('View on site'), obj.get_absolute_url())

    def _rescore(self, request, problem_id):
        from judge.tasks import rescore_problem
        transaction.on_commit(rescore_problem.s(problem_id).delay)

    @admin.display(description=_('Set publish date to now'))
    def update_publish_date(self, request, queryset):
        count = queryset.update(date=timezone.now())
        self.message_user(request, ngettext("%d problem's publish date successfully updated.",
                                            "%d problems' publish date successfully updated.",
                                            count) % count)

    @admin.display(description=_('Mark problems as public'))
    def make_public(self, request, queryset):
        if not request.user.has_perm('judge.change_public_visibility'):
            queryset = queryset.filter(is_organization_private=True)
        count = queryset.update(is_public=True)
        for problem_id in queryset.values_list('id', flat=True):
            self._rescore(request, problem_id)
        self.message_user(request, ngettext('%d problem successfully marked as public.',
                                            '%d problems successfully marked as public.',
                                            count) % count)

    @admin.display(description=_('Mark problems as private'))
    def make_private(self, request, queryset):
        if not request.user.has_perm('judge.change_public_visibility'):
            queryset = queryset.filter(is_organization_private=True)
        count = queryset.update(is_public=False)
        for problem_id in queryset.values_list('id', flat=True):
            self._rescore(request, problem_id)
        self.message_user(request, ngettext('%d problem successfully marked as private.',
                                            '%d problems successfully marked as private.',
                                            count) % count)

    def get_queryset(self, request):
        return Problem.get_editable_problems(request.user).prefetch_related('authors__user').distinct()

    def has_change_permission(self, request, obj=None):
        if obj is None:
            return request.user.has_perm('judge.edit_own_problem')
        return obj.is_editable_by(request.user)

    def formfield_for_manytomany(self, db_field, request=None, **kwargs):
        if db_field.name == 'allowed_languages':
            kwargs['widget'] = CheckboxSelectMultipleWithSelectAll()
        return super(ProblemAdmin, self).formfield_for_manytomany(db_field, request, **kwargs)

    def get_form(self, *args, **kwargs):
        form = super(ProblemAdmin, self).get_form(*args, **kwargs)
        form.base_fields['authors'].queryset = Profile.objects.all()
        return form

    def save_model(self, request, obj, form, change):
        # `organizations` will not appear in `cleaned_data` if user cannot edit it
        if form.changed_data and 'organizations' in form.changed_data:
            obj.is_organization_private = bool(form.cleaned_data['organizations'])

        # Parse uploaded problem package (if any) for identification fields.
        cfg = {}
        try:
            pkg_file = form.files.get('problem_package')
        except Exception:
            pkg_file = None

        if pkg_file:
            try:
                data = pkg_file.read()
                z = zipfile.ZipFile(io.BytesIO(data))
                try:
                    with z.open('config.json') as cj:
                        cfg = json.load(cj)
                except KeyError:
                    try:
                        with z.open('.judge/config.json') as cj:
                            cfg = json.load(cj)
                    except KeyError:
                        cfg = {}
            except Exception:
                cfg = {}

        pid = cfg.get('problem_id') or cfg.get('problemID') if cfg else None
        pname = cfg.get('problem_name') or cfg.get('problemName') or cfg.get('problem') if cfg else None
        pdesc = cfg.get('description') if cfg else None

        if pid and not getattr(obj, 'code', None):
            obj.code = ''.join(ch for ch in pid.lower() if ch.isalnum())
        if pname and not getattr(obj, 'name', None):
            obj.name = pname
        if pdesc and not getattr(obj, 'description', None):
            obj.description = pdesc

        # Apply server-side defaults unconditionally so DB constraints are satisfied.
        if not getattr(obj, 'code', None):
            ts = timezone.now().strftime('p%Y%m%d%H%M%S')
            obj.code = (ts + uuid.uuid4().hex[:4]).lower()
        if not getattr(obj, 'name', None):
            obj.name = _('Untitled problem')
        if not getattr(obj, 'description', None):
            obj.description = gettext('No description provided.')
        if not getattr(obj, 'time_limit', None):
            obj.time_limit = 30
        if not getattr(obj, 'memory_limit', None):
            obj.memory_limit = 65536
        if not getattr(obj, 'points', None):
            obj.points = 100
        if not getattr(obj, 'group', None):
            try:
                grp = ProblemGroup.objects.filter(name='default').first()
                if not grp:
                    grp = ProblemGroup.objects.first()
                if not grp:
                    grp = ProblemGroup.objects.create(name='default', full_name='Default')
                obj.group = grp
            except Exception:
                pass

        if form.cleaned_data.get('is_public') and not request.user.has_perm('judge.change_public_visibility'):
            if not obj.is_organization_private:
                raise PermissionDenied
            if not request.user.has_perm('judge.create_private_problem'):
                raise PermissionDenied

        super(ProblemAdmin, self).save_model(request, obj, form, change)
        # If an admin uploaded a problem package file, persist it to ProblemData.
        # This ensures packages uploaded during problem creation/edit are saved.
        if pkg_file:
            try:
                from judge.models import ProblemData
                pdata, _ = ProblemData.objects.get_or_create(problem=obj)
                # Use the FileField save helper to store the uploaded file.
                pdata.zipfile.save(pkg_file.name, pkg_file, save=False)
                try:
                    pdata.package_size = getattr(pkg_file, 'size', None)
                except Exception:
                    pdata.package_size = None
                try:
                    pdata.package_uploaded_at = timezone.now()
                except Exception:
                    pdata.package_uploaded_at = None
                # Also store a package_path reference (storage-relative) so
                # consumers can prefer this path over the FileField. Use the
                # FileField's name which is typically '<code>/<basename>'.
                try:
                    pdata.package_path = pdata.zipfile.name
                except Exception:
                    pass
                pdata.save()
                # Publish package event so other services/consumers can react
                try:
                    logger = logging.getLogger('judge.admin.problem')
                    payload = {
                        'problem_id': getattr(obj, 'id', None),
                        'code': getattr(obj, 'code', None),
                        'name': getattr(obj, 'name', None),
                        'package_path': getattr(pdata, 'package_path', None),
                        'package_size': getattr(pdata, 'package_size', None),
                        'package_uploaded_at': (pdata.package_uploaded_at.isoformat()
                                                if getattr(pdata, 'package_uploaded_at', None) else None),
                    }
                    try:
                        package_event_publisher.publish(payload)
                        logger.info('Published package event for problem %s', obj.code)
                    except Exception:
                        logger.exception('Failed to publish package event for problem %s', obj.code)
                except Exception:
                    # Keep package persistence resilient: don't break main save on publish failures
                    logging.getLogger('judge.admin.problem').exception('Error while preparing package event for problem %s', getattr(obj, 'code', None))
            except Exception:
                # Don't let package save failures block the main save operation.
                pass
        if (
            form.changed_data and
            any(f in form.changed_data for f in ('is_public', 'organizations', 'points', 'partial'))
        ):
            self._rescore(request, obj.id)

        # After save, ensure M2M required fields have defaults if still empty.
        try:
            if not obj.allowed_languages.exists():
                py = Language.get_python3()
                obj.allowed_languages.add(py)
        except Exception:
            pass

        try:
            if not obj.types.exists():
                # Ensure a default ProblemType exists and attach it.
                ptype, _ = ProblemType.objects.get_or_create(name='default', defaults={'full_name': 'Default'})
                obj.types.add(ptype)
        except Exception:
            pass

    def construct_change_message(self, request, form, *args, **kwargs):
        if form.cleaned_data.get('change_message'):
            return form.cleaned_data['change_message']
        return super(ProblemAdmin, self).construct_change_message(request, form, *args, **kwargs)


class ProblemPointsVoteAdmin(admin.ModelAdmin):
    list_display = ('points', 'voter', 'linked_problem', 'vote_time')
    search_fields = ('voter__user__username', 'problem__code', 'problem__name')
    readonly_fields = ('voter', 'problem', 'vote_time')

    def get_queryset(self, request):
        return ProblemPointsVote.objects.filter(problem__in=Problem.get_editable_problems(request.user))

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        if obj is None:
            return request.user.has_perm('judge.edit_own_problem')
        return obj.problem.is_editable_by(request.user)

    def lookup_allowed(self, key, value):
        return super().lookup_allowed(key, value) or key in ('problem__code',)

    @admin.display(description=_('problem'), ordering='problem__name')
    def linked_problem(self, obj):
        link = reverse('problem_detail', args=[obj.problem.code])
        return format_html('<a href="{0}">{1}</a>', link, obj.problem.name)
