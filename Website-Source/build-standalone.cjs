// Optional packaging utility; the generated HTML does not require Node.
const fs=require('node:fs');
const path=require('node:path');
let html=fs.readFileSync(path.join(__dirname,'index.html'),'utf8');
html=html.replace('<link rel="stylesheet" href="style.css">',()=>'<style>'+fs.readFileSync(path.join(__dirname,'style.css'),'utf8')+'</style>');
const scripts=['samples.js','engine.js','app.js'];
for(const file of scripts)html=html.replace(`<script defer src="${file}"></script>`,'');
const embedded=scripts.map(file=>'<script>\n'+fs.readFileSync(path.join(__dirname,file),'utf8').replace(/<\/script/gi,'<\\/script')+'\n</script>').join('\n');
html=html.replace('</body>',()=>embedded+'\n</body>');
fs.writeFileSync(path.join(__dirname,'DermaLab-Offline.html'),html);
console.log('Created self-contained DermaLab-Offline.html');
