// Run with UndertaleModCli 0.9.2.0 load path/to/data.win -s path/to/this.csx
// Writes a new metadata/audio folder beside data.win; does not modify the build.
using System;
using System.IO;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using UndertaleModLib;
using UndertaleModLib.Models;
using Newtonsoft.Json;
string root = Path.Combine(Path.GetDirectoryName(FilePath), "Samurai_Runner_Recovery_Metadata");
Directory.CreateDirectory(root+"/assets/audio");
Directory.CreateDirectory(root+"/metadata");
object Walk(object o, int depth=0, bool expand=false) {
 if(o==null) return null;
 var t=o.GetType();
 if(o is UndertaleString us) return us.Content;
 if(t.IsPrimitive || o is string || o is decimal) return o;
 if(t.IsEnum || o is Guid) return o.ToString();
 if(o is byte[] b) return new {bytes=b.Length,base64=Convert.ToBase64String(b)};
 if(!expand && o is UndertaleNamedResource nr) return nr.Name?.Content;
 if(depth>12) return "[depth limit]";
 if(o is IEnumerable en) { var a=new List<object>();foreach(var e in en) a.Add(Walk(e,depth+1));return a; }
 var d=new Dictionary<string,object>();
 foreach(var p in t.GetProperties()) {
  if(!p.CanRead || p.GetIndexParameters().Length>0 || p.Name.StartsWith("Project") || p.Name=="ParentRoom" || p.Name=="ParentLayer")continue;
  try{d[p.Name]=Walk(p.GetValue(o),depth+1);}catch(Exception ex){d[p.Name]="[unreadable: "+ex.Message+"]";}
 }
 return d;
}
void Save(string f,object o) {File.WriteAllText(root+"/metadata/"+f+".json",JsonConvert.SerializeObject(o,Formatting.Indented));}
Save("general",Walk(Data.GeneralInfo,0,true));
Save("sprites",Data.Sprites.Select(x=>Walk(x,0,true)).ToArray());
Save("objects",Data.GameObjects.Select(x=>Walk(x,0,true)).ToArray());
Save("rooms",Data.Rooms.Select(x=>Walk(x,0,true)).ToArray());
Save("sounds",Data.Sounds.Select(x=>Walk(x,0,true)).ToArray());
Save("texture_items",Data.TexturePageItems.Select(x=>Walk(x,0,true)).ToArray());
Save("asset_order",new {sprites=Data.Sprites.Select(x=>x?.Name?.Content),objects=Data.GameObjects.Select(x=>x?.Name?.Content),rooms=Data.Rooms.Select(x=>x?.Name?.Content),sounds=Data.Sounds.Select(x=>x?.Name?.Content),code=Data.Code.Select(x=>x?.Name?.Content)});
foreach(var s in Data.Sounds) {
 var b=s.AudioFile.Data;
 string ext=(b[0]==79 && b[1]==103)?".ogg":".wav";
 File.WriteAllBytes(root+"/assets/audio/"+s.Name.Content+ext,b);
}
Console.WriteLine("Metadata and all "+Data.Sounds.Count+" embedded sounds exported.");
