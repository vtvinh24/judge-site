import os

from django.core.management.base import BaseCommand, CommandError

from judge.models.problem import Problem
from judge.handlers.problem_package import create_problem_package


class Command(BaseCommand):
    help = 'Import a problem package file for an existing problem code.'

    def add_arguments(self, parser):
        parser.add_argument('problem_code', help='Problem code to attach the package to')
        parser.add_argument('package_path', help='Path to a local package file to import')
        parser.add_argument('--pkg-version', dest='version', help='Optional package version string', default=None)

    def handle(self, *args, **options):
        code = options['problem_code']
        path = options['package_path']
        version = options.get('version')

        if not os.path.exists(path):
            raise CommandError('package_path does not exist: %s' % path)

        try:
            problem = Problem.objects.get(code=code)
        except Problem.DoesNotExist:
            raise CommandError('Unknown problem code: %s' % code)

        pdata = create_problem_package(problem, path, package_version=version)
        self.stdout.write(self.style.SUCCESS('Imported package for %s -> %s' % (code, pdata.zipfile.name)))
