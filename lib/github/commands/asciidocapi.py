#!/usr/bin/env python
"""
asciidocapi - AsciiDoc API wrapper class.

The AsciiDocAPI class provides an API for executing asciidoc. Minimal example
compiles `mydoc.txt` to `mydoc.html`:

  import asciidocapi
  asciidoc = asciidocapi.AsciiDocAPI()
  asciidoc.execute('mydoc.txt')

- Full documentation in asciidocapi.txt.
- See the doctests below for more examples.

Doctests:

1. Check execution:

   >>> import StringIO
   >>> infile = StringIO.StringIO('Hello *{author}*')
   >>> outfile = StringIO.StringIO()
   >>> asciidoc = AsciiDocAPI()
   >>> asciidoc.options('--no-header-footer')
   >>> asciidoc.attributes['author'] = 'Joe Bloggs'
   >>> asciidoc.execute(infile, outfile, backend='html4')
   >>> print outfile.getvalue()
   <p>Hello <strong>Joe Bloggs</strong></p>

   >>> asciidoc.attributes['author'] = 'Bill Smith'
   >>> infile = StringIO.StringIO('Hello _{author}_')
   >>> outfile = StringIO.StringIO()
   >>> asciidoc.execute(infile, outfile, backend='docbook')
   >>> print outfile.getvalue()
   <simpara>Hello <emphasis>Bill Smith</emphasis></simpara>

2. Check error handling:

   >>> import StringIO
   >>> asciidoc = AsciiDocAPI()
   >>> infile = StringIO.StringIO('---------')
   >>> outfile = StringIO.StringIO()
   >>> asciidoc.execute(infile, outfile)
   Traceback (most recent call last):
     File "<stdin>", line 1, in <module>
     File "asciidocapi.py", line 189, in execute
       raise AsciiDocError(self.messages[-1])
   AsciiDocError: ERROR: <stdin>: line 1: [blockdef-listing] missing closing delimiter


Copyright (C) 2009 Stuart Rackham. Free use of this software is granted
under the terms of the GNU General Public License (GPL).

"""

import sys,os,re

API_VERSION = '0.1.1'
MIN_ASCIIDOC_VERSION = '8.4.1'  # Minimum acceptable AsciiDoc version.


def find_in_path(fname, path=None):
    """
    Find file fname in paths. Return None if not found.
    """
    if path is None:
        path = os.environ.get('PATH', '')
    for dir in path.split(os.pathsep):
        fpath = os.path.join(dir, fname)
        if os.path.isfile(fpath):
            return fpath
    else:
        return None


class AsciiDocError(Exception):
    pass


class Options(object):
    """
    Stores asciidoc(1) command options.
    """
    def __init__(self, values=[]):
        self.values = values[:]
    def __call__(self, name, value=None):
        """Shortcut for append method."""
        self.append(name, value)
    def append(self, name, value=None):
        if type(value) in (int,float):
            value = str(value)
        self.values.append((name,value))


class Version(object):
    """
    Parse and compare AsciiDoc version numbers. Instance attributes:

    string: String version number '<major>.<minor>[.<micro>][suffix]'.
    major:  Integer major version number.
    minor:  Integer minor version number.
    micro:  Integer micro version number.
    suffix: Suffix (begins with non-numeric character) is ignored when
            comparing.

    Doctest examples:

    >>> Version('8.2.5') < Version('8.3 beta 1')
    True
    >>> Version('8.3.0') == Version('8.3. beta 1')
    True
    >>> Version('8.2.0') < Version('8.20')
    True
    >>> Version('8.20').major
    8
    >>> Version('8.20').minor
    20
    >>> Version('8.20').micro
    0
    >>> Version('8.20').suffix
    ''
    >>> Version('8.20 beta 1').suffix
    'beta 1'

    """
    def __init__(self, version):
        self.string = version
        reo = re.match(r'^(\d+)\.(\d+)(\.(\d+))?\s*(.*?)\s*$', self.string)
        if not reo:
            raise ValueError('invalid version number: %s' % self.string)
        groups = reo.groups()
        self.major = int(groups[0])
        self.minor = int(groups[1])
        self.micro = int(groups[3] or '0')
        self.suffix = groups[4] or ''
    def __cmp__(self, other):
        result = cmp(self.major, other.major)
        if result == 0:
            result = cmp(self.minor, other.minor)
            if result == 0:
                result = cmp(self.micro, other.micro)
        return result


class AsciiDocAPI(object):
    """
    AsciiDoc API class.
    """
    def __init__(self, asciidoc_py=None):
        """
        Locate and import asciidoc.py.
        Initialize instance attributes.
        """
        self.options = Options()
        self.attributes = {}
        self.messages = []
        # Search for the asciidoc command file.
        # Try ASCIIDOC_PY environment variable first.
        cmd = os.environ.get('ASCIIDOC_PY')
        if cmd:
            if not os.path.isfile(cmd):
                raise AsciiDocError('missing ASCIIDOC_PY file: %s' % cmd)
        elif asciidoc_py:
            # Next try path specified by caller.
            cmd = asciidoc_py
            if not os.path.isfile(cmd):
                raise AsciiDocError('missing file: %s' % cmd)
        else:
            # Try shell search paths.
            for fname in ['asciidoc.py','asciidoc.pyc','asciidoc']:
                cmd = find_in_path(fname)
                if cmd: break
            else:
                # Finally try current working directory.
                for cmd in ['asciidoc.py','asciidoc.pyc','asciidoc']:
                    if os.path.isfile(cmd): break
                else:
                    raise AsciiDocError('failed to locate asciidoc.py[c]')
        cmd = os.path.realpath(cmd)
        if os.path.splitext(cmd)[1] not in ['.py','.pyc']:
            raise AsciiDocError('invalid Python module name: %s' % cmd)
        sys.path.insert(0, os.path.dirname(cmd))
        try:
            try:
                import asciidoc
            except ImportError:
                raise AsciiDocError('failed to import asciidoc')
        finally:
            del sys.path[0]
        if Version(asciidoc.VERSION) < Version(MIN_ASCIIDOC_VERSION):
            raise AsciiDocError(
                'asciidocapi %s requires asciidoc %s or better'
                % (API_VERSION, MIN_ASCIIDOC_VERSION))
        self.asciidoc = asciidoc
        self.cmd = cmd

    def execute(self, infile, outfile=None, backend=None):
        """
        Compile infile to outfile using backend format.
        infile can outfile can be file path strings or file like objects.
        """
        self.messages = []
        opts = Options(self.options.values)
        if outfile is not None:
            opts('--out-file', outfile)
        if backend is not None:
            opts('--backend', backend)
        for k,v in self.attributes.items():
            if v == '' or k[-1] in '!@':
                s = k
            elif v is None: # A None value undefines the attribute.
                s = k + '!'
            else:
                s = '%s=%s' % (k,v)
            opts('--attribute', s)
        args = [infile]
        sys.path.insert(0, os.path.dirname(self.cmd))
        try:
            # The AsciiDoc command was designed to process source text then
            # exit, there are globals and statics in asciidoc.py that have
            # to be reinitialized before each run -- hence the reload.
            reload(self.asciidoc)
        finally:
            del sys.path[0]
        try:
            try:
                self.asciidoc.execute(self.cmd, opts.values, args)
            finally:
                self.messages = self.asciidoc.messages[:]
        except SystemExit, e:
            if e.code:
                raise AsciiDocError(self.messages[-1])


if __name__ == "__main__":
    """
    Run module doctests.
    """
    import doctest
    options = doctest.NORMALIZE_WHITESPACE + doctest.ELLIPSIS
    doctest.testmod(optionflags=options)
