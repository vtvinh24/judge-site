from django.db import models
from django.utils.translation import gettext_lazy as _


class ResultEvent(models.Model):
    """Stores evaluation results/events emitted by an external JUDGE for submissions.

    The payload structure follows `judge-docs/schemas/result_event.schema.json` and
    uses JSON fields for flexible storage of rubrics, metadata and artifacts.
    """
    event_id = models.CharField(max_length=100, verbose_name=_('event id'), db_index=True)
    event_type = models.CharField(max_length=100, verbose_name=_('event type'))
    event_time = models.DateTimeField(verbose_name=_('event time'))
    source = models.CharField(max_length=100, verbose_name=_('source'))

    # Core payload fields
    submission_id = models.CharField(max_length=100, verbose_name=_('submission id'), db_index=True)
    problem_id = models.CharField(max_length=100, verbose_name=_('problem id'), db_index=True)
    status = models.CharField(max_length=20, verbose_name=_('status'))
    evaluated_at = models.DateTimeField(verbose_name=_('evaluated at'), null=True, blank=True)
    execution_status = models.CharField(max_length=100, verbose_name=_('execution status'), null=True, blank=True)
    # Use BooleanField with null=True (NullBooleanField removed in recent Django)
    timed_out = models.BooleanField(verbose_name=_('timed out'), null=True)

    total_score = models.FloatField(verbose_name=_('total score'), null=True, blank=True)
    max_score = models.FloatField(verbose_name=_('max score'), null=True, blank=True)
    percentage = models.FloatField(verbose_name=_('percentage'), null=True, blank=True)

    # Flexible JSON blobs for rubrics, metadata and artifacts; using JSONField keeps
    # the model extensible and easier to map back to the upstream event payload.
    rubrics = models.JSONField(verbose_name=_('rubrics'), null=True, blank=True)
    metadata = models.JSONField(verbose_name=_('metadata'), null=True, blank=True)
    artifacts = models.JSONField(verbose_name=_('artifacts'), null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True, verbose_name=_('created at'))

    class Meta:
        verbose_name = _('result event')
        verbose_name_plural = _('result events')
        indexes = [
            models.Index(fields=['submission_id']),
            models.Index(fields=['problem_id']),
            models.Index(fields=['event_id']),
        ]

    def __str__(self):
        return '%s: %s for %s' % (self.event_type, self.event_id, self.submission_id)
