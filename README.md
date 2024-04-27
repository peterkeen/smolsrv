1. from: somebody@example.com
   to: vendors@keenfamily.us
   id: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

2. from: vendors@keenfamily.us
   to: peter.keen@gmail.com
   id: <def@smol.keenfamily.us>

   from: vendors@keenfamily.us
   to: eni889@gmail.com
   id: <ghi@smol.keenfamily.us>

   received: {
     <abc@gmail.com> => somebody@example.com
   }

   sent: {
     <def@smol.keenfamily.us> => peter.keen@gmail.com, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => eni889@gmail.com, <abc@gmail.com>
   }

3. from: peter.keen@gmail.com
   to: vendors@keenfamily.us
   id: <jkl@gmail.com>
   in-reply-to: <def@smol.keenfamily.us>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => peter.keen@gmail.com
   }

   sent: {
     <def@smol.keenfamily.us> => peter.keen@gmail.com, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => eni889@gmail.com, <abc@gmail.com>
   }

4. from: vendors@keenfamily.us
   to: eni889@gmail.com
   id: <mno@smol.keenfamily.us>
   in-reply-to: <ghi@smol.keenfamily.us>

   from: vendors@keenfamily.us
   to: somebody@example.com
   id: <pqr@smol.keenfamily.us>
   in-reply-to: <abc@gmail.com>

   received: {
     <abc@gmail.com> => somebody@example.com,
     <jkl@gmail.com> => peter.keen@gmail.com
   }

   sent: {
     <def@smol.keenfamily.us> => peter.keen@gmail.com, <abc@gmail.com>,
     <ghi@smol.keenfamily.us> => eni889@gmail.com, <abc@gmail.com>
     <mno@smol.keenfamily.us> => eni889@gmail.com, <ghi@smol.keenfamily.us>,
     <pqr@smol.keenfamily.us> => somebody@example.com, <abc@gmail.com>
   }
