using UAssetAPI;
using UAssetAPI.ExportTypes;
using UAssetAPI.UnrealTypes;
using UAssetAPI.Unversioned;
using Newtonsoft.Json.Linq;

if (args.Length is not (3 or 5)) throw new ArgumentException("mapping source output [research.json localization.json]");
var mappings = new Usmap(args[0]);
var specs = args.Length == 5 ? JArray.Parse(File.ReadAllText(args[3])) : null;
var catalog = args.Length == 5 ? JArray.Parse(File.ReadAllText(args[4])) : null;
UAsset Read(string path) {
    var a = new UAsset(EngineVersion.VER_UE5_6, mappings) {
        FilePath = Path.GetFullPath(path), PayloadEngineVersionOverride = EngineVersion.VER_UE5_8 };
    using(var r = a.PathToReader(a.FilePath)) a.Read(r);
    if(a.Exports.Any(e => e is RawExport) || !a.VerifyBinaryEquality())
        throw new Exception("Non-lossless skill read: " + path);
    return a;
}
var results = new List<object>();
foreach(var path in Directory.GetFiles(args[1], "DA_Skill_*.uasset", SearchOption.AllDirectories).OrderBy(p=>p)) {
    var a = Read(path);
    var before = JObject.Parse(a.SerializeJson(true));
    var json = (JObject)before.DeepClone();
    var data = (JArray)json["Exports"]![0]!["Data"]!;
    var unlock = (JArray)data.Single(t=>(string?)t["Name"]=="Unlock")["Value"]!;
    var cost = unlock.SingleOrDefault(t=>(string?)t["Name"]=="Cost");
    var level = unlock.SingleOrDefault(t=>(string?)t["Name"]=="Requirement");
    var name = Path.GetFileNameWithoutExtension(path);
    var spec = specs?.SingleOrDefault(s=>(string?)s["asset"]==name);
    var dest = Path.Combine(args[2], Path.GetRelativePath(args[1],path));
    Directory.CreateDirectory(Path.GetDirectoryName(dest)!);
    if(spec != null) {
        if(cost == null || (int)cost["Value"]! != 0) throw new Exception("Unexpected baseline cost: " + name);
        cost["Value"] = spec["cost"]!.DeepClone();
        cost["IsZero"] = false;
        var description = data.Single(t=>(string?)t["Name"]=="Description");
        var entry = catalog!.Single(t=>(string?)t["key"]==(string?)description["Value"]);
        description["CultureInvariantString"] = entry["en"]!.DeepClone();
        var edited=UAsset.DeserializeJson(json.ToString());
        edited.Mappings=mappings; edited.PayloadEngineVersionOverride=EngineVersion.VER_UE5_8;
        edited.Write(dest);
        var check = JObject.Parse(Read(dest).SerializeJson(true));
        foreach(var root in new[]{json,check}) {
            foreach(var e in (JArray)root["Exports"]!) {
                ((JObject)e).Remove("SerialSize"); ((JObject)e).Remove("SerialOffset");
            }
        }
        if(!JToken.DeepEquals(json["Exports"],check["Exports"]) || !JToken.DeepEquals(before["Imports"],check["Imports"]))
            throw new Exception("Skill semantic mismatch: " + name);
        File.WriteAllText(dest+".json",check.ToString());
    } else File.WriteAllText(dest+".json",json.ToString());
    results.Add(new {asset=name,cost=(int?)cost?["Value"],level=(int?)level?["Value"],changed=spec!=null});
}
File.WriteAllText(Path.Combine(args[2],"skills.json"),Newtonsoft.Json.JsonConvert.SerializeObject(results,Newtonsoft.Json.Formatting.Indented));
Console.WriteLine(File.ReadAllText(Path.Combine(args[2],"skills.json")));
