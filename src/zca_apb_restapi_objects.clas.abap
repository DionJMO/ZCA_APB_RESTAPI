CLASS zca_apb_restapi_objects DEFINITION
INHERITING FROM cl_rest_resource
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: if_rest_resource~get REDEFINITION,
      get_all_objects,
      get_objects_per_table
        IMPORTING
          iv_table_id TYPE zca_apb_tables-id.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mo_model TYPE REF TO zca_apb_objects_model.
ENDCLASS.

CLASS zca_apb_restapi_objects IMPLEMENTATION.

  METHOD if_rest_resource~get.
    DATA: lt_assigned_objects TYPE TABLE OF zca_apb_assign,
          lt_table_name       TYPE zca_apb_tables-name,
          lv_table_id         TYPE zca_apb_tables-id,
          l_uri               TYPE string.

    IF mo_model IS INITIAL.
      CREATE OBJECT mo_model TYPE zca_apb_objects_model.
    ENDIF.

    "URI holen
    l_uri = me->mo_request->get_uri( ).

    "response-handler anlegen
    mo_response->create_entity( ).

    IF find( val = l_uri regex = '\/tables\/\d+/objects$'   ) <> -1.

      " Tisch-ID aus URL-Parameter extrahieren
      lv_table_id = mo_request->get_uri_attribute( iv_name = 'tableId' ).
      IF lv_table_id IS NOT INITIAL.
        me->get_objects_per_table( iv_table_id = lv_table_id ).
      ELSE.
        "Fehlerbehandlung, falls keine ID gefunden wurde
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Bad Request: No ID provided').
      ENDIF.
    ELSEIF find( val = l_uri regex = '\/objects$' ) <> -1.
      me->get_all_objects( ).
    ELSE.

      mo_response->set_header_field(
       EXPORTING
         iv_name  = 'Access-Control-Allow-Origin'
         iv_value = '*.kroschke.com'
     ).

      mo_response->set_header_field(
     EXPORTING
       iv_name  = 'Content-Security-Policy'
       iv_value = '*.kroschke.com'
   ).

      mo_response->get_entity( )->set_string_data( '{ "msg": "OK!" }' ).
      mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
    ENDIF.
  ENDMETHOD.
  METHOD get_all_objects.
    DATA: lt_objects TYPE zca_apb_objects_model=>tt_result.

    " Überprüfen, ob mo_model initialisiert wurde
    IF mo_model IS INITIAL.
      " Fehlerbehandlung, z.B. Initialisieren von mo_model oder Ausgabe einer Fehlermeldung
      RAISE EXCEPTION TYPE cx_sy_ref_is_initial.
    ENDIF.

    lt_objects = mo_model->get_objects( ).

    IF lt_objects IS NOT INITIAL.
      " Statuscode auf 200 OK setzen, da Datensätze gefunden wurden
      mo_response->set_status( iv_status = 200 ).
      " Die gefundenen Datensätze als JSON serialisieren und als Antwort setzen
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_objects
          compress    = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case

      ) ).
    ELSE.
      " Statuscode auf 204 No Content setzen, da keine Datensätze gefunden wurden
      mo_response->set_status( iv_status = 204 iv_reason_phrase = 'No Entries found!' ).
    ENDIF.
    " Den Content-Type der Antwort auf application/json setzen
    mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
  ENDMETHOD.
  METHOD get_objects_per_table.
    DATA: lt_assign TYPE zca_apb_objects_model=>tt_result.


    " Überprüfen, ob mo_model initialisiert wurde
    IF mo_model IS INITIAL.
      " Fehlerbehandlung, z.B. Initialisieren von mo_model oder Ausgabe einer Fehlermeldung
      RAISE EXCEPTION TYPE cx_sy_ref_is_initial.
    ENDIF.
    lt_assign = mo_model->get_assigned_objects_by_table( iv_table_id = iv_table_id ).

    IF lt_assign IS NOT INITIAL.
      " Statuscode auf 200 OK setzen, da Datensätze gefunden wurden
      mo_response->set_status( iv_status = 200 ).
      " Die gefundenen Datensätze als JSON serialisieren und als Antwort setzen
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_assign
          compress    = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case

      ) ).
    ELSE.
      " Statuscode auf 204 No Content setzen, da keine Datensätze gefunden wurden
      mo_response->set_status( iv_status = 204 iv_reason_phrase = 'No Entries found!' ).
    ENDIF.
    " Den Content-Type der Antwort auf application/json setzen
    mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
  ENDMETHOD.
ENDCLASS.

