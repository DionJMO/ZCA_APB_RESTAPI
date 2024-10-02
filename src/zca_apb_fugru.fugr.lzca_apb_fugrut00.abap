*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCA_APB_ASSIGN..................................*
DATA:  BEGIN OF STATUS_ZCA_APB_ASSIGN                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCA_APB_ASSIGN                .
CONTROLS: TCTRL_ZCA_APB_ASSIGN
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZCA_APB_BOOKING.................................*
DATA:  BEGIN OF STATUS_ZCA_APB_BOOKING               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCA_APB_BOOKING               .
CONTROLS: TCTRL_ZCA_APB_BOOKING
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZCA_APB_OBJECTS.................................*
DATA:  BEGIN OF STATUS_ZCA_APB_OBJECTS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCA_APB_OBJECTS               .
CONTROLS: TCTRL_ZCA_APB_OBJECTS
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZCA_APB_TABLES..................................*
DATA:  BEGIN OF STATUS_ZCA_APB_TABLES                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCA_APB_TABLES                .
CONTROLS: TCTRL_ZCA_APB_TABLES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCA_APB_ASSIGN                .
TABLES: *ZCA_APB_BOOKING               .
TABLES: *ZCA_APB_OBJECTS               .
TABLES: *ZCA_APB_TABLES                .
TABLES: ZCA_APB_ASSIGN                 .
TABLES: ZCA_APB_BOOKING                .
TABLES: ZCA_APB_OBJECTS                .
TABLES: ZCA_APB_TABLES                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
