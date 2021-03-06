###
### Load greenGenesDB into namespace
###

.onLoad <- function(libname, pkgname)
{
    ns <- asNamespace(pkgname)
    seq_file <- system.file("extdata", 'gg_13_5_seq.rds',
                            package=pkgname, lib.loc=libname)

    db_taxa_file <- system.file("extdata", "gg_13_5.sqlite3",
                                package=pkgname, lib.loc=libname)

    if(!file.exists(seq_file) || !file.exists(db_taxa_file)){
        packageStartupMessage("Greengenes 13.5 database data not present, use `get_greengenesDb.R` In the package inst/scripts directory to downlod the database into the package inst/extdata/ directory and reinstall the package")
    }

    metadata = list(URL = "https://greengenes.microbio.me",
                    DB_TYPE_NAME = "GreenGenes",
                    DB_VERSION = "gg_13_5",
                    ACCESSION_DATE = "March 11, 2016")

    ## load database sequence object
    db_seq <- readRDS(seq_file)

    ## initiate new MgDB object
    ggMgDb <- new("MgDb",
                  seq = db_seq,
                  taxa_file = db_taxa_file,
                  tree_file = "not available",
                  metadata = metadata)

    assign("gg13.5MgDb", ggMgDb, envir=ns)
    namespaceExport(ns, "gg13.5MgDb")

}
