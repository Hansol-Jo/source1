*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSAPLANE_A25...................................*
DATA:  BEGIN OF STATUS_ZTSAPLANE_A25                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSAPLANE_A25                 .
CONTROLS: TCTRL_ZTSAPLANE_A25
            TYPE TABLEVIEW USING SCREEN '0040'.
*...processing: ZTSCARR_A25.....................................*
DATA:  BEGIN OF STATUS_ZTSCARR_A25                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSCARR_A25                   .
CONTROLS: TCTRL_ZTSCARR_A25
            TYPE TABLEVIEW USING SCREEN '0020'.
*...processing: ZTSFLIGHT_A25...................................*
DATA:  BEGIN OF STATUS_ZTSFLIGHT_A25                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSFLIGHT_A25                 .
CONTROLS: TCTRL_ZTSFLIGHT_A25
            TYPE TABLEVIEW USING SCREEN '0030'.
*...processing: ZTSPFLI_A25.....................................*
DATA:  BEGIN OF STATUS_ZTSPFLI_A25                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPFLI_A25                   .
CONTROLS: TCTRL_ZTSPFLI_A25
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZTSAPLANE_A25                 .
TABLES: *ZTSCARR_A25                   .
TABLES: *ZTSFLIGHT_A25                 .
TABLES: *ZTSPFLI_A25                   .
TABLES: ZTSAPLANE_A25                  .
TABLES: ZTSCARR_A25                    .
TABLES: ZTSFLIGHT_A25                  .
TABLES: ZTSPFLI_A25                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
