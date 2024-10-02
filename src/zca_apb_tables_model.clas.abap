CLASS zca_apb_tables_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " tt - TabellenTyp
    TYPES: tt_tables TYPE TABLE OF zca_apb_tables WITH DEFAULT KEY.
    METHODS: get_tables
      RETURNING VALUE(rt_tables) TYPE tt_tables,
      get_single_table
      IMPORTING
        !iv_id           TYPE zca_apb_tables-id
        RETURNING VALUE(rs_table) TYPE zca_apb_tables.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zca_apb_tables_model IMPLEMENTATION.
  METHOD get_tables.
    SELECT * FROM zca_apb_tables INTO TABLE @rt_tables.
  ENDMETHOD.

  METHOD get_single_table.
    SELECT SINGLE * FROM zca_apb_tables INTO @rs_table WHERE id = @iv_id.
    IF sy-subrc <> 0.
      CLEAR rs_table.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
