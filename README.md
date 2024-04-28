Smolsrv is a silly little listsrv. The tiniest listsrv. Barely more than automatic bcc.

```
1. from: somebody@example.com
   to: list@example.net
   id: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

2. from: list@example.net
   to: pete@example.org
   id: <def@smol.example.net>

   from: list@example.net
   to: fred@example.org
   id: <ghi@smol.example.net>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

   sent: {
     <def@smol.example.net> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.example.net> => fred@example.org, <abc@gmail.com>
   }

3. from: pete@example.org
   to: list@example.net
   id: <jkl@gmail.com>
   in-reply-to: <def@smol.example.net>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => pete@example.org
   }

   sent: {
     <def@smol.example.net> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.example.net> => fred@example.org, <abc@gmail.com>
   }

4. from: list@example.net
   to: fred@example.org
   id: <mno@smol.example.net>
   in-reply-to: <ghi@smol.example.net>

   from: list@example.net
   to: somebody@example.com
   id: <pqr@smol.example.net>
   in-reply-to: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => pete@example.org
   }

   sent: {
     <def@smol.example.net> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.example.net> => fred@example.org, <abc@gmail.com>
     <mno@smol.example.net> => fred@example.org, <ghi@smol.example.net>,
     <pqr@smol.example.net> => somebody@example.com, <abc@gmail.com>
   }
```
