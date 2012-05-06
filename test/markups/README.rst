Header 1
========

Example text.

Header 2
--------

1. Blah blah ``code`` blah

2. More ``code``, hooray

3. Somé UTF-8°

Some Python code
----------------

.. code:: python

    import sys

    def foo():
        print("Hello there!")

    foo()

Some Ruby code
----------------

.. code:: ruby

    def test_fails_gracefully_on_missing_env_commands
        GitHub::Markup.command('/usr/bin/env totally_fake', /tf/)
        text = 'hey mang'
        assert GitHub::Markup.can_render?('README.tf')
        actual = GitHub::Markup.render('README.tf', text)
        assert_equal text, actual
    end

some PHP code
-------------

.. code:: php

    <?php

    $foo = 1;
    $bar = 2;

