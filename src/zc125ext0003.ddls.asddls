@AbapCatalog.sqlViewAppendName: 'ZC125EXT0003_V'
@EndUserText.label: '[C1] Fake Standard Table Extend'
extend view ZC125CDS0003 with ZC125EXT0003 
{
    ztsa2505.zzsaknr,
    ztsa2505.zzkostl,
    ztsa2505.zzshkzg,
    ztsa2505.zzlgort
}
