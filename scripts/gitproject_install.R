library(devtools)
library(getPass)
devtools::install_git(
  "git://gitlab.com/bartk/uvaRadar.git", #url of a git project you want to install
  credentials = git2r::cred_user_pass("MaBr13", getPass::getPass()) #uname is your username
)


cred <- git2r::cred_user_pass(rstudioapi::askForPassword("username"), rstudioapi::askForPassword("Password"))
devtools::install_git("git://gitlab.com/bartk/uvaRadar.git", credentials = cred,ref = 'master')

remotes::install_git("git://gitlab.com/bartk/uvaRadar.git",credentials=git2r::cred_user_pass("MaBr13", "55nebitno992@"))

remotes::install_local('C:/Users/mbradar/Downloads/uvaradar-master.zip')

# ----
s3_set_key(username = "MaBr13",
           password = "55nebitno992@")

uvaRadar::s3_set_key(username = "MaBr13", # ACCES_KEY
                     password = "55nebitno992@", # SECRET_KEY
                     service = getOption("uvaRadar.AWS_S3_ENDPOINT"),
                     keyring = NULL)

Sys.setenv("AWS_ACCESS_KEY_ID" = "MaBr13",
           "AWS_SECRET_ACCESS_KEY" = "55nebitno992@",
           "AWS_DEFAULT_REGION" = "fnwi-s0.science.uva.nl:9001")

aws.s3::bucketlist(use_https = T,
                   add_region = F,
                   base_url = "fnwi-s0.science.uva.nl:9001")

exists_ret = aws.s3::head_object(bucket = "exppvol",
                                 object = "long_pulse/UK/CHE/2019/04/07/UKCHE_pvol_20190407T2010_03675.h5",
                                 use_https = T,
                                 check_region = F,
                                 base_url = "fnwi-s0.science.uva.nl:9001")
pvol <- retrieve_pvol('long_pulse/UK/CHE/2019/04/07/UKCHE_vp_20190407T1635_03675.h5')
