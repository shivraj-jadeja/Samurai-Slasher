"""Static graph and lossless asset checks; not a substitute for runtime tests."""
from pathlib import Path
import json,re,hashlib,sys
from PIL import Image

root=Path(sys.argv[1]) if len(sys.argv)>1 else (Path(__file__).parent.parent if Path(__file__).parent.name=='qa' else Path(__file__).parent/'source')
pack=root/'RecoveryEvidence' if (root/'RecoveryEvidence').exists() else Path(__file__).parent/'recovery/Samurai_Runner_Rebuild_Pack'
def read(p):return json.loads(re.sub(r',\s*([}\]])',r'\1',p.read_text(encoding='utf-8-sig')))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=read(root/'Samurai Slasher.yyp')
resources={x['id']['name']:x['id']['path'] for x in p['resources']}
assert len(resources)==len(p['resources'])
folders={f['folderPath'] for f in p['Folders']}
frames=0
for m in read(pack/'metadata/asset_manifest.json'):
    name=m['resource'];s=read(root/resources[name]);d=root/'sprites'/name
    assert len(s['frames'])==m['frames']
    assert s['width']==m['width'] and s['height']==m['height']
    assert s['sequence']['xorigin']==m['origin_x_original'] and s['sequence']['yorigin']==m['origin_y_original']
    assert s['sequence']['playbackSpeed']==m['playback_speed'] and s['sequence']['playbackSpeedType']==0
    assert s['bboxMode']==2 and s['collisionKind']==1
    assert all(s[k]==m[k] for k in ['bbox_left','bbox_top','bbox_right','bbox_bottom'])
    keys=s['sequence']['tracks'][0]['keyframes']['Keyframes']
    assert len(keys)==len(s['frames']) and s['sequence']['length']==m['frames']
    for i,f in enumerate(s['frames']):
        recovered=pack/m['frames_directory']/f'{i:03}.png'
        composite=d/(f['name']+'.png');layer=d/'layers'/f['name']/(s['layers'][0]['name']+'.png')
        assert sha(recovered)==sha(composite)==sha(layer),(name,i,'changed bytes')
        assert Image.open(composite).size==(m['width'],m['height'])
        assert Image.open(composite).mode=='RGBA'
        assert keys[i]['Key']==i and keys[i]['Channels']['0']['Id']['name']==f['name']
        assert keys[i]['Channels']['0']['Id']['path']==resources[name]
        frames+=1
    assert len(list(d.glob('*.png')))==m['frames'],'orphan composite frames'
for m in read(pack/'metadata/sounds.json'):
    name=m['Name'];s=read(root/resources[name])
    assert sha(root/'sounds'/name/s['soundFile'])==sha(pack/'assets/audio'/(name+'.wav'))
for m in read(pack/'metadata/objects.json'):
    obj=read(root/resources[m['Name']])
    assert (obj['parentObjectId'] or {}).get('name')==m['ParentId']
    assert (obj['spriteId'] or {}).get('name')==m['Sprite']
    assert not obj['solid'] and not obj['persistent'] and not obj['physicsObject']
    types={0:'Create',1:'Destroy',3:'Step',7:'Other',8:'Draw',12:'CleanUp'}
    for event in obj['eventList']:
        assert (root/'objects'/m['Name']/f"{types[event['eventType']]}_{event['eventNum']}.gml").exists()
def check_refs(node):
    if isinstance(node,dict):
        path=node.get('path')
        if path and path.endswith('.yy'):
            assert path in folders or (root/path).is_file(),path
        for v in node.values():check_refs(v)
    elif isinstance(node,list):
        for v in node:check_refs(v)
for path in resources.values():check_refs(read(root/path))
check_refs(p)
assert [n['roomId']['name'] for n in p['RoomOrderNodes']]==['Room1','rm_congrats']
for name in ['Room1','rm_congrats']:
    room=read(root/resources[name]);instances={i['name'] for layer in room['layers'] for i in layer.get('instances',[])}
    assert instances=={i['name'] for i in room['instanceCreationOrder']}
text='\n'.join(f.read_text() for category in ['scripts','objects'] for f in (root/category).rglob('*.gml'))
assert text.count('enum SamuraiForm')==1
assert not re.search(r'UnknownEnum|\barg\d+\b|asset_get_index\(',text)
assert frames==132
report={'static_checks':'PASS','resources':len(resources),'sprites':39,'frames':frames,'sounds':3,'objects':23,'rooms':2,
        'asset_bytes':'All composite/layer PNGs and WAVs match recovery SHA-256',
        'graph':'All references, sequence keys, events and room creation-order entries resolve',
        'runtime_checks':'Reported separately in TEST_REPORT.md'}
print(json.dumps(report,indent=2))
