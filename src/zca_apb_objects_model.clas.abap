CLASS zca_apb_objects_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    " Definiert eine Tabelle von Objekten mit Standard-Schlüssel.
    TYPES:
      tt_objects TYPE TABLE OF zca_apb_objects WITH DEFAULT KEY,
      " Struktur für das Ergebnis der Zuweisungen.
      BEGIN OF ty_result,
        mandt          TYPE mandt,
        assingment_id  TYPE zca_apb_assign-assingment_id,
        table_id       TYPE zca_apb_assign-table_id,
        table_name     TYPE zca_apb_tables-name,
        table_color    TYPE zca_apb_tables-color,
        table_material TYPE zca_apb_tables-material,
        svg_id         TYPE zca_apb_tables-svg_id,
        object_id      TYPE zca_apb_assign-object_id,
        object_name    TYPE zca_apb_objects-name,
        quantity       TYPE zca_apb_assign-quantity,
      END OF ty_result,
      " Tabelle für Ergebnisstrukturen.
      tt_result TYPE TABLE OF ty_result WITH DEFAULT KEY.
    " Methode, um zugewiesene Objekte nach Tisch-ID zu erhalten.
    METHODS: get_assigned_objects_by_table
      IMPORTING iv_table_id                TYPE zca_apb_tables-id
      RETURNING VALUE(rt_assigned_objects) TYPE tt_result,
      " Methode, um alle Objekte zu erhalten.
      get_objects
        RETURNING VALUE(rt_objects) TYPE tt_result.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zca_apb_objects_model IMPLEMENTATION.
  METHOD get_assigned_objects_by_table.
    " Temporäre Tabelle für Ergebnisse der Datenbankabfrage.
    DATA: lt_results TYPE tt_result.

    " Selektiert Daten durch Verknüpfen der Zuweisungs-, Tisch- und Objekttabellen.
    SELECT ass~mandt, ass~assingment_id, ass~table_id, tab~name AS table_name, tab~color AS table_color,
            tab~material AS table_material,
           ass~object_id, obj~name AS object_name, ass~quantity, tab~svg_id AS svg_id
      INTO CORRESPONDING FIELDS OF TABLE @lt_results
      FROM zca_apb_assign AS ass
      INNER JOIN zca_apb_tables AS tab ON ass~table_id = tab~id
      INNER JOIN zca_apb_objects AS obj ON ass~object_id = obj~id
      WHERE ass~table_id = @iv_table_id.
    " Rückgabe der abgefragten Daten.
    rt_assigned_objects = lt_results.
  ENDMETHOD.
  METHOD get_objects.
    " Temporäre Tabelle für Ergebnisse der Datenbankabfrage.
    DATA: lt_results TYPE tt_result.

    " Selektiert Daten durch Verknüpfen der Zuweisungs-, Tisch- und Objekttabellen.
    SELECT ass~mandt, ass~assingment_id, ass~table_id, tab~name AS table_name, tab~color AS table_color,
            tab~material AS table_material,
           ass~object_id, obj~name AS object_name, ass~quantity, tab~svg_id AS svg_id
      INTO CORRESPONDING FIELDS OF TABLE @lt_results
      FROM zca_apb_assign AS ass
      INNER JOIN zca_apb_tables AS tab ON ass~table_id = tab~id
      INNER JOIN zca_apb_objects AS obj ON ass~object_id = obj~id.

    " Rückgabe der abgefragten Daten.
    rt_objects = lt_results.
  ENDMETHOD.
ENDCLASS.

