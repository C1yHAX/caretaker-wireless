using UAssetAPI;
using UAssetAPI.ExportTypes;
using UAssetAPI.UnrealTypes;
using UAssetAPI.Unversioned;

if (args.Length != 4) throw new ArgumentException("Usage: mapping.usmap input.json output.uasset stock-schema.uasset");
var asset = UAsset.DeserializeJson(File.ReadAllText(args[1]));
asset.Mappings = new Usmap(args[0]);
asset.PayloadEngineVersionOverride = EngineVersion.VER_UE5_8;
// Reading the matching stock donor registers its dependent Blueprint schemas,
// including the native wireless octree component used by every radio.
var donor = new UAsset(EngineVersion.VER_UE5_6, asset.Mappings) {
    FilePath = args[3], PayloadEngineVersionOverride = EngineVersion.VER_UE5_8
};
using (var reader = donor.PathToReader(args[3])) donor.Read(reader);
foreach (var export in asset.Exports.OfType<StructExport>()) {
    var schema = Usmap.GetSchemaFromStructExport(export, true);
    asset.Mappings.Schemas[export.ObjectName.ToString()] = schema;
    if (!string.IsNullOrEmpty(schema.ModulePath))
        asset.Mappings.Schemas[schema.ModulePath + "." + export.ObjectName] = schema;
}
if (asset.Exports.Any(e => e is RawExport)) throw new Exception("Unparsed export");
typeof(UAsset).GetField("NamesReferencedFromExportDataCount",
    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic)!
    .SetValue(asset, asset.GetNameMapIndexList().Count);
Directory.CreateDirectory(Path.GetDirectoryName(args[2])!);
asset.Write(args[2]);
var roundtrip = new UAsset(EngineVersion.VER_UE5_6, asset.Mappings) {
    FilePath = args[2], PayloadEngineVersionOverride = EngineVersion.VER_UE5_8
};
using (var reader = roundtrip.PathToReader(args[2])) roundtrip.Read(reader);
if (roundtrip.Exports.Any(e => e is RawExport) || !roundtrip.VerifyBinaryEquality())
    throw new Exception("Binary roundtrip failed");
File.WriteAllText(args[2] + ".checked.json", roundtrip.SerializeJson(true));
Console.WriteLine("Verified " + Path.GetFileName(args[2]));
