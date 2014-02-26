Header 1
========

Example text.

Header 2
--------

1. Blah blah ``code`` blah

2. More ``code``, hooray

3. Somé UTF-8°

==============  ==========================================================
Travis          http://travis-ci.org/tony/pullv
Docs            http://pullv.rtfd.org
API             http://pullv.readthedocs.org/en/latest/api.html
Issues          https://github.com/tony/pullv/issues
Source          https://github.com/tony/pullv
==============  ==========================================================

blockdiag
---------

.. blockdiag::

   {
     A -> B -> C;
          B -> D;
   }

seqdiag
-------

.. seqdiag::

   seqdiag {
     browser  -> webserver [label = "GET /index.html"];
     browser <-- webserver;
     browser  -> webserver [label = "POST /blog/comment"];
                 webserver  -> database [label = "INSERT comment"];
                 webserver <-- database;
     browser <-- webserver;
   }

actdiag
-------

.. actdiag::

   actdiag {
     write -> convert -> image

     lane user {
        label = "User"
        write [label = "Writing reST"];
        image [label = "Get diagram IMAGE"];
     }
     lane actdiag {
        convert [label = "Convert reST to Image"];
     }
   }

nwdiag
------

.. nwdiag::

   nwdiag {
     network dmz {
         address = "210.x.x.x/24"

         web01 [address = "210.x.x.1"];
         web02 [address = "210.x.x.2"];
     }
     network internal {
         address = "172.x.x.x/24";

         web01 [address = "172.x.x.1"];
         web02 [address = "172.x.x.2"];
         db01;
         db02;
     }
   }
