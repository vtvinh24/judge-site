import json
import mimetypes
import os
from itertools import chain
from typing import List
from zipfile import BadZipfile, ZipFile

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.exceptions import ValidationError
from django.forms import BaseModelFormSet, HiddenInput, ModelForm, NumberInput, Select, formset_factory
from django.http import Http404, HttpResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.urls import reverse
from django.utils.html import escape, format_html
from django.utils.safestring import mark_safe
from django.utils.translation import gettext as _
from django.views.generic import DetailView

from judge.highlight_code import highlight_code
from judge.models import Problem, ProblemData, ProblemTestCase, Submission, problem_data_storage
from judge.utils.problem_data import ProblemDataCompiler
from judge.utils.unicode import utf8text
from judge.utils.views import TitleMixin, add_file_response
from judge.views.problem import ProblemMixin
from judge.models import Problem, ProblemData, problem_data_storage
import os
from django.shortcuts import get_object_or_404
from django.http import HttpResponse, Http404

mimetypes.init()
mimetypes.add_type('application/x-yaml', '.yml')


def checker_args_cleaner(self):
    data = self.cleaned_data['checker_args']
    if not data or data.isspace():
        return ''
    try:
        if not isinstance(json.loads(data), dict):
            raise ValidationError(_('Checker arguments must be a JSON object.'))
    except ValueError:
        raise ValidationError(_('Checker arguments is invalid JSON.'))
    return data


class ProblemDataForm(ModelForm):
    def clean_zipfile(self):
        if hasattr(self, 'zip_valid') and not self.zip_valid:
            raise ValidationError(_('Your zip file is invalid!'))

        zipfile = self.cleaned_data['zipfile']
        if zipfile and not zipfile.name.endswith('.zip'):
            raise ValidationError(_("Zip files must end in '.zip'"))

        return zipfile

    def clean_generator(self):
        generator = self.cleaned_data['generator']
        if generator and generator.name == 'init.yml':
            raise ValidationError(_('Generators must not be named init.yml.'))

        return generator

    clean_checker_args = checker_args_cleaner

    class Meta:
        model = ProblemData
        fields = ['zipfile', 'generator', 'unicode', 'nobigmath', 'output_limit', 'output_prefix',
                  'checker', 'checker_args']
        widgets = {
            'checker_args': HiddenInput,
        }


class ProblemCaseForm(ModelForm):
    clean_checker_args = checker_args_cleaner

    class Meta:
        model = ProblemTestCase
        fields = ('order', 'type', 'input_file', 'output_file', 'points', 'is_pretest', 'output_limit',
                  'output_prefix', 'checker', 'checker_args', 'generator_args', 'batch_dependencies')
        widgets = {
            'generator_args': HiddenInput,
            'batch_dependencies': HiddenInput,
            'type': Select(attrs={'style': 'width: 100%'}),
            'points': NumberInput(attrs={'style': 'width: 4em'}),
            'output_prefix': NumberInput(attrs={'style': 'width: 4.5em'}),
            'output_limit': NumberInput(attrs={'style': 'width: 6em'}),
            'checker_args': HiddenInput,
        }


class ProblemCaseFormSet(formset_factory(ProblemCaseForm, formset=BaseModelFormSet, extra=1, max_num=1,
                                         can_delete=True)):
    model = ProblemTestCase

    def __init__(self, *args, **kwargs):
        self.valid_files = kwargs.pop('valid_files', None)
        super(ProblemCaseFormSet, self).__init__(*args, **kwargs)

    def _construct_form(self, i, **kwargs):
        form = super(ProblemCaseFormSet, self)._construct_form(i, **kwargs)
        form.valid_files = self.valid_files
        return form


class ProblemManagerMixin(LoginRequiredMixin, ProblemMixin, DetailView):
    def get_object(self, queryset=None):
        problem = super(ProblemManagerMixin, self).get_object(queryset)
        if problem.is_manually_managed:
            raise Http404()
        if self.request.user.is_superuser or problem.is_editable_by(self.request.user):
            return problem
        raise Http404()


class ProblemSubmissionDiff(TitleMixin, ProblemMixin, DetailView):
    template_name = 'problem/submission-diff.html'

    def get_title(self):
        return _('Comparing submissions for {0}').format(self.object.name)

    def get_content_title(self):
        return mark_safe(escape(_('Comparing submissions for {0}')).format(
            format_html('<a href="{1}">{0}</a>', self.object.name, reverse('problem_detail', args=[self.object.code])),
        ))

    def get_object(self, queryset=None):
        problem = super(ProblemSubmissionDiff, self).get_object(queryset)
        if self.request.user.is_superuser or problem.is_editable_by(self.request.user):
            return problem
        raise Http404()

    def get_context_data(self, **kwargs):
        context = super(ProblemSubmissionDiff, self).get_context_data(**kwargs)
        try:
            ids = self.request.GET.getlist('id')
            subs = Submission.objects.filter(id__in=ids)
        except ValueError:
            raise Http404
        if not subs:
            raise Http404

        context['submissions'] = subs

        # If we have associated data we can do better than just guess
        data = ProblemTestCase.objects.filter(dataset=self.object, type='C')
        if data:
            num_cases = data.count()
        else:
            num_cases = subs.first().test_cases.count()
        context['num_cases'] = num_cases
        return context


class ProblemDataView(TitleMixin, ProblemManagerMixin):
    template_name = 'problem/data.html'

    def get_title(self):
        return _('Editing data for {0}').format(self.object.name)

    def get_content_title(self):
        return mark_safe(escape(_('Editing data for %s')) % (
            format_html('<a href="{1}">{0}</a>', self.object.name,
                        reverse('problem_detail', args=[self.object.code]))))

    def get_data_form(self, post=False):
        return ProblemDataForm(data=self.request.POST if post else None, prefix='problem-data',
                               files=self.request.FILES if post else None,
                               instance=ProblemData.objects.get_or_create(problem=self.object)[0])

    def get_case_formset(self, files, post=False):
        return ProblemCaseFormSet(data=self.request.POST if post else None, prefix='cases', valid_files=files,
                                  queryset=ProblemTestCase.objects.filter(dataset_id=self.object.pk).order_by('order'))

    def get_valid_files(self, data, post=False) -> List[str]:
        try:
            if post and 'problem-data-zipfile-clear' in self.request.POST:
                return []
            elif post and 'problem-data-zipfile' in self.request.FILES:
                return ZipFile(self.request.FILES['problem-data-zipfile']).namelist()
            # Prefer package_path when available (it may point to a storage-relative
            # path or an external URL). If it's an external URL we can't read
            # entries here, so fall back to zipfile or return empty list.
            elif getattr(data, 'package_path', None):
                pp = data.package_path
                if pp and (pp.startswith('http://') or pp.startswith('https://')):
                    return []
                # If package_path already references the problem directory use it
                # directly; otherwise assume basename lives under the problem code
                code = data.problem.code
                prefix1 = code + os.sep
                prefix2 = code + '/'
                if pp.startswith(prefix1) or pp.startswith(prefix2):
                    file_rel = pp
                else:
                    file_rel = os.path.join(code, os.path.basename(pp))
                return ZipFile(problem_data_storage.path(file_rel)).namelist()
            elif data.zipfile:
                # zipfile.path may not be available for all storage backends; try
                # to use storage path resolution to be defensive.
                try:
                    return ZipFile(data.zipfile.path).namelist()
                except Exception:
                    file_rel = os.path.join(data.problem.code, os.path.basename(data.zipfile.name))
                    return ZipFile(problem_data_storage.path(file_rel)).namelist()
        except BadZipfile:
            raise
        return []

    def get_context_data(self, **kwargs):
        context = super(ProblemDataView, self).get_context_data(**kwargs)
        valid_files = []
        if 'data_form' not in context:
            context['data_form'] = self.get_data_form()
            try:
                valid_files = self.get_valid_files(context['data_form'].instance)
            except BadZipfile:
                pass
        context['valid_files'] = set(valid_files)
        context['valid_files_json'] = mark_safe(json.dumps(valid_files))

        context['cases_formset'] = self.get_case_formset(valid_files)
        context['all_case_forms'] = chain(context['cases_formset'], [context['cases_formset'].empty_form])
        return context

    def post(self, request, *args, **kwargs):
        self.object = problem = self.get_object()
        data_form = self.get_data_form(post=True)
        try:
            valid_files = self.get_valid_files(data_form.instance, post=True)
            data_form.zip_valid = True
        except BadZipfile:
            valid_files = []
            data_form.zip_valid = False

        cases_formset = self.get_case_formset(valid_files, post=True)
        if data_form.is_valid() and cases_formset.is_valid():
            data = data_form.save()
            for case in cases_formset.save(commit=False):
                case.dataset_id = problem.id
                case.save()
            for case in cases_formset.deleted_objects:
                case.delete()
            ProblemDataCompiler.generate(problem, data, problem.cases.order_by('order'), valid_files)
            return HttpResponseRedirect(request.get_full_path())
        return self.render_to_response(self.get_context_data(data_form=data_form, cases_formset=cases_formset,
                                                             valid_files=valid_files))

    put = post


@login_required
def problem_data_file(request, problem, path):
    object = get_object_or_404(Problem, code=problem)
    if not object.is_editable_by(request.user):
        raise Http404()

    problem_dir = problem_data_storage.path(problem)
    if os.path.commonpath((problem_data_storage.path(os.path.join(problem, path)), problem_dir)) != problem_dir:
        raise Http404()

    response = HttpResponse()

    if hasattr(settings, 'DMOJ_PROBLEM_DATA_INTERNAL'):
        url_path = '%s/%s/%s' % (settings.DMOJ_PROBLEM_DATA_INTERNAL, problem, path)
    else:
        url_path = None

    try:
        add_file_response(request, response, url_path, os.path.join(problem, path), problem_data_storage)
    except IOError:
        raise Http404()

    response['Content-Type'] = 'application/octet-stream'
    return response


@login_required
def problem_init_view(request, problem):
    problem = get_object_or_404(Problem, code=problem)
    if not problem.is_editable_by(request.user):
        raise Http404()

    try:
        with problem_data_storage.open(os.path.join(problem.code, 'init.yml'), 'rb') as f:
            data = utf8text(f.read()).rstrip('\n')
    except IOError:
        raise Http404()

    return render(request, 'problem/yaml.html', {
        'raw_source': data, 'highlighted_source': highlight_code(data, 'yaml'),
        'title': _('Generated init.yml for %s') % problem.name,
        'content_title': mark_safe(escape(_('Generated init.yml for %s')) % (
            format_html('<a href="{1}">{0}</a>', problem.name,
                        reverse('problem_detail', args=[problem.code])))),
    })


def problem_package_download(request, problem):
    """Public endpoint to download the problem package archive.

    TODO: Add authentication/authorization (currently intentionally unauthenticated for testing).
    """
    # Resolve problem object
    obj = get_object_or_404(Problem, code=problem)

    # Ensure ProblemData exists and has a zipfile
    try:
        pdata = ProblemData.objects.get(problem=obj)
    except ProblemData.DoesNotExist:
        raise Http404()

    # Prefer package_path when present. If it's an external URL redirect to it.
    if getattr(pdata, 'package_path', None):
        pp = pdata.package_path
        if pp and (pp.startswith('http://') or pp.startswith('https://')):
            return HttpResponseRedirect(pp)
        # Otherwise treat package_path as a storage-relative path. If it already
        # references the problem directory, use it directly; else assume the
        # basename lives under the problem code directory.
        problem_dir = problem_data_storage.path(obj.code)
        prefix1 = obj.code + os.sep
        prefix2 = obj.code + '/'
        if pp.startswith(prefix1) or pp.startswith(prefix2):
            file_rel = pp
        else:
            file_rel = os.path.join(obj.code, os.path.basename(pp))
        file_abs = problem_data_storage.path(file_rel)
        if os.path.commonpath((file_abs, problem_dir)) != problem_dir:
            raise Http404()
    else:
        # Fallback to zipfile-based serving for backward compatibility
        if not pdata.zipfile:
            raise Http404()
        problem_dir = problem_data_storage.path(obj.code)
        # Use basename to be defensive
        file_rel = os.path.join(obj.code, os.path.basename(pdata.zipfile.name))
        file_abs = problem_data_storage.path(file_rel)
        if os.path.commonpath((file_abs, problem_dir)) != problem_dir:
            raise Http404()

    response = HttpResponse()
    try:
        # Use add_file_response to support X-Accel-Redirect where configured
        add_file_response(request, response, None, file_rel, problem_data_storage)
    except IOError:
        raise Http404()

    # Force download
    response['Content-Type'] = 'application/octet-stream'
    # Determine a sensible filename for Content-Disposition. Prefer the
    # resolved storage-relative path (file_rel) if available, else prefer
    # package_path, then zipfile.name, otherwise fallback.
    try:
        if 'file_rel' in locals() and file_rel:
            filename = os.path.basename(file_rel)
        elif getattr(pdata, 'package_path', None):
            filename = os.path.basename(pdata.package_path)
        elif getattr(pdata, 'zipfile', None):
            filename = os.path.basename(pdata.zipfile.name)
        else:
            filename = 'package.zip'
    except Exception:
        filename = 'package.zip'

    response['Content-Disposition'] = 'attachment; filename="%s"' % filename
    return response
