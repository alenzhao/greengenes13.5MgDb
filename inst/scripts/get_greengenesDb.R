### =========================================================================
### Downloading database greengenes 13_5 database
### Assumes script is run from the inst/script directory of the package

library(dplyr)
library(RSQLite)
library(Biostrings)

.fetch_db <- function(db_url){
    f_name = tempfile()
    download.file(url = db_url, destfile = f_name, method = "curl")
    return(f_name)
}

.load_taxa <- function(taxonomy_file, db_con){
    # Create the database
    taxa=read.delim(taxonomy_file,stringsAsFactors=FALSE,header=FALSE)
    keys = taxa[,1]
    taxa = strsplit(taxa[,2],split="; ")
    taxa = t(sapply(taxa,function(i){i}))
    taxa = cbind(keys,taxa)
    colnames(taxa) = c("Keys","Kingdom","Phylum","Class","Order","Family","Genus","Species")
    taxa = data.frame(taxa)
    dplyr::copy_to(db_con,taxa,temporary=FALSE, indexes=list(colnames(taxa)))
    file.remove(taxonomy_file)
}

getGreenGenes13.5Db <- function(
        db_name = "gg_13_5",
        seq_url = "https://gembox.cbcb.umd.edu/gg135/gg_13_5.fasta.gz",
        taxa_url = "https://gembox.cbcb.umd.edu/gg135/gg_13_5_taxonomy.txt.gz"
){
        # downloading database sequence data
        seq_file <- .fetch_db(seq_url)
        db_seq <- Biostrings::readDNAStringSet(seq_file)
        saveRDS(db_seq, file = paste0("../extdata/",db_name,"_seq.rds"))

        # downloading taxa data and building sqlite db
        db_taxa_file <- paste0("../extdata/",db_name, ".sqlite3")
        db_con <- dplyr::src_sqlite(db_taxa_file, create = T)
        taxonomy_file <- .fetch_db(taxa_url)
        .load_taxa(taxonomy_file, db_con)

}

getGreenGenes13.5Db()
