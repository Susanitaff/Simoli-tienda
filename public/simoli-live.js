// Complemento público del catálogo SimOli. Solo lee productos PUBLICADOS.
// La autorización de escrituras NO depende de este archivo, sino de RLS de Supabase.
(()=>{'use strict';
document.addEventListener('DOMContentLoaded',async()=>{
const conf=window.SIMOLI_CONFIG||{};
if(!conf.supabaseUrl||!conf.supabasePublishableKey)return;
if(!window.supabase?.createClient||!window.SimOliStore?.apply){console.warn('SimOli: catálogo no enlazado');return}
try {
  const client=window.supabase.createClient(conf.supabaseUrl,conf.supabasePublishableKey);
  const {data,error}=await client.from('simoli_products')
    .select('id,name,brand,category,description,price,stock,condition,image_url,published').eq('published',true).order('name');
  if(error)throw error;
  window.SimOliStore.apply(data||[]);
} catch(err){console.warn('SimOli: no se pudo actualizar catálogo en vivo; se muestra la copia de demostración.',err);}
});
})();