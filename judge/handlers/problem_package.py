import io
import os
import uuid
import zipfile
import tarfile
import hashlib

from django.core.files.base import ContentFile
from django.utils import timezone

from judge.models.problem_data import ProblemData, problem_data_storage


def _list_archive_members(path):
    """Return a set of filenames contained in a zip or tar archive at path."""
    members = set()
    try:
        if zipfile.is_zipfile(path):
            with zipfile.ZipFile(path) as zf:
                for info in zf.infolist():
                    # normalize to basename (what ProblemDataCompiler expects)
                    members.add(os.path.basename(info.filename))
            return members
    except Exception:
        pass
    try:
        if tarfile.is_tarfile(path):
            with tarfile.open(path) as tf:
                for member in tf.getmembers():
                    members.add(os.path.basename(member.name))
            return members
    except Exception:
        pass
    return members


def _compute_checksum_and_size(storage, name):
    """Compute sha256 checksum and size (bytes) of a file stored in `storage` under `name`."""
    h = hashlib.sha256()
    size = 0
    with storage.open(name, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            size += len(chunk)
            h.update(chunk)
    return h.hexdigest(), size


def create_problem_package(problem, package_file, filename=None, package_version=None, generate_init=True):
    """Create or update ProblemData for `problem` from the given package_file.

    - problem: Problem instance
    - package_file: a file-like object (with read()/chunks()) or a filesystem path string
    - filename: optional filename to store (defaults to provided filename or generated)
    - package_version: optional version string
    - generate_init: if True, run the ProblemDataCompiler to generate init.yml

    Returns the ProblemData instance.
    """
    # Obtain or create ProblemData
    try:
        pdata = problem.data_files
    except Exception:
        pdata = ProblemData(problem=problem)

    # Prepare filename
    if filename is None:
        if isinstance(package_file, str):
            filename = os.path.basename(package_file)
        else:
            filename = 'package-%s.zip' % uuid.uuid4().hex[:8]

    # Read content from different types of inputs
    if isinstance(package_file, str):
        # filesystem path
        with open(package_file, 'rb') as f:
            data = f.read()
    else:
        # file-like (UploadedFile or file object)
        try:
            # Django UploadedFile supports chunks()
            chunks = package_file.chunks()
            buf = io.BytesIO()
            for chunk in chunks:
                buf.write(chunk)
            data = buf.getvalue()
        except Exception:
            # fallback to read()
            package_file.seek(0)
            data = package_file.read()

    # Save file into storage via FileField
    pdata.zipfile.save(filename, ContentFile(data))

    # Compute checksum and size
    checksum, size = _compute_checksum_and_size(problem_data_storage, pdata.zipfile.name)

    # Fill metadata
    pdata.package_checksum = checksum
    pdata.package_size = size
    pdata.package_version = package_version
    pdata.package_uploaded_at = timezone.now()
    # Generate a package_id now so we can reference it externally
    pdata.package_id = pdata.package_id or uuid.uuid4().hex

    pdata.save()

    # Optionally generate init.yml using ProblemDataCompiler
    if generate_init:
        # collect case objects and archive members
        cases = list(problem.cases.all().order_by('order'))
        try:
            archive_path = problem_data_storage.path(pdata.zipfile.name)
            files = _list_archive_members(archive_path)
        except Exception:
            files = set()

        # Import the compiler lazily to avoid circular imports
        from judge.utils.problem_data import ProblemDataCompiler
        try:
            ProblemDataCompiler.generate(problem, pdata, cases, files)
        except Exception:
            # Compiler errors should not break the handler; store feedback instead
            try:
                pdata.feedback = 'Failed to generate init.yml'
                pdata.save(update_fields=('feedback',))
            except Exception:
                pass

    return pdata
