const assert=require('node:assert/strict');
const {classify,features,process}=require('./engine.js');
for(const [mean,label,subclass] of [[130,'Benign','Psoriasis'],[131,'Malignant','SSM'],[149,'Malignant','SSM'],[150,'Malignant','NM'],[163,'Normal','—'],[169,'Malignant','NM'],[170,'Benign','Psoriasis'],[203,'Normal','—']]){const c=classify(mean);assert.equal(c.label,label);assert.equal(c.subclass,subclass);}
const flat=Uint8ClampedArray.from([100,100,100,255,100,100,100,255]);assert.equal(features(flat).mean,100);assert.equal(features(flat).sd,0);assert.equal(features(flat).entropy,0);assert.equal(process(flat,2,1).coverage,0);
const known=features(Uint8ClampedArray.from([0,0,0,255,255,255,255,255]));assert.equal(known.mean,127.5);assert.equal(known.entropy,1);assert.equal(known.skewness,0);assert.equal(known.kurtosis,1);
const w=32,h=32,pixels=new Uint8ClampedArray(w*h*4);for(let y=0;y<h;y++)for(let x=0;x<w;x++){const i=(y*w+x)*4;const v=x>=10&&x<22&&y>=10&&y<22?20:230;pixels.set([v,v,v,255],i);}const segmented=process(pixels,w,h);assert.ok(segmented.mask[16*w+16]);assert.equal(segmented.mask[0],0);assert.ok(segmented.coverage>10&&segmented.coverage<20);assert.ok(segmented.box.width>=10&&segmented.box.width<=14);
console.log('Passed: classification boundary cases, statistical invariants, uniform-image handling, synthetic-region segmentation.');
