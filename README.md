1. from: somebody@example.com
   to: list@example.net
   id: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

2. from: list@example.net
   to: pete@example.org
   id: <def@smol.keenfamily.us>

   from: list@example.net
   to: fred@example.org
   id: <ghi@smol.keenfamily.us>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

   sent: {
     <def@smol.keenfamily.us> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => fred@example.org, <abc@gmail.com>
   }

3. from: pete@example.org
   to: list@example.net
   id: <jkl@gmail.com>
   in-reply-to: <def@smol.keenfamily.us>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => pete@example.org
   }

   sent: {
     <def@smol.keenfamily.us> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => fred@example.org, <abc@gmail.com>
   }

4. from: list@example.net
   to: fred@example.org
   id: <mno@smol.keenfamily.us>
   in-reply-to: <ghi@smol.keenfamily.us>

   from: list@example.net
   to: somebody@example.com
   id: <pqr@smol.keenfamily.us>
   in-reply-to: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => pete@example.org
   }

   sent: {
     <def@smol.keenfamily.us> => pete@example.org, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => fred@example.org, <abc@gmail.com>
     <mno@smol.keenfamily.us> => fred@example.org, <ghi@smol.keenfamily.us>,
     <pqr@smol.keenfamily.us> => somebody@example.com, <abc@gmail.com>
   }
