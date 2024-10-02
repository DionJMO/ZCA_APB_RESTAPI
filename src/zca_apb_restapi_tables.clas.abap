CLASS zca_apb_restapi_tables DEFINITION
  INHERITING FROM cl_rest_resource
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: if_rest_resource~get REDEFINITION,
      get_single_table
        IMPORTING
          iv_table_id TYPE zca_apb_tables-id,

      get_all_tables.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_model TYPE REF TO zca_apb_tables_model.
ENDCLASS.

CLASS zca_apb_restapi_tables IMPLEMENTATION.

  METHOD if_rest_resource~get.
    DATA:
      l_uri      TYPE string,
      l_table_id TYPE zca_apb_tables-id.

    "
    IF mo_model IS INITIAL.
      CREATE OBJECT mo_model TYPE zca_apb_tables_model.
    ENDIF.

    "URI holen
    l_uri = me->mo_request->get_uri( ).

    "response-handler anlegen
    mo_response->create_entity( ).

    IF find( val = l_uri regex = '\/tables\/\d+$' ) <> -1.
      " Extrahieren der Tisch-ID aus der URI
      l_table_id = me->mo_request->get_uri_attribute( iv_name = 'id' ).
      IF l_table_id IS NOT INITIAL.
        me->get_single_table( iv_table_id = l_table_id ).
      ELSE.
        "Fehlerbehandlung, falls keine ID gefunden wurde
        mo_response->set_status( iv_status = 400 iv_reason_phrase = 'Bad Request: No ID provided').
      ENDIF.

      " Prüfen, ob die Anfrage an die /tables-Ressource gerichtet ist
    ELSEIF find( val = l_uri regex = '\/tables$'   ) <> -1.

      " Holt sich die Daten aus der Model-Klasse
      me->get_all_tables( ).


    ELSE.
      " Wenn die URI nicht mit /tables übereinstimmt, Standard-Antwort senden
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
  METHOD get_all_tables.
    DATA: lt_tables TYPE TABLE OF zca_apb_tables.

    " Holt sich die Daten aus der Model-Klasse
    lt_tables = mo_model->get_tables( ).

    " Prüfen, ob Datensätze gefunden wurden
    IF lt_tables IS NOT INITIAL.
      " Statuscode auf 200 OK setzen, da Datensätze gefunden wurden
      mo_response->set_status( iv_status = 200 ).
      " Die gefundenen Datensätze als JSON serialisieren und als Antwort setzen
      mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
          data        = lt_tables
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

  METHOD get_single_table.
    " Diese Methode wird aufgerufen, wenn ein spezifischer Tisch nach ID angefordert wird
    DATA: l_table_id TYPE zca_apb_tables-id,
          ls_table   TYPE zca_apb_tables.

    TRY.
        " Extrahieren der Tisch-ID aus der URI
        l_table_id = me->mo_request->get_uri_attribute( iv_name = 'id' ).

        " Überprüfen, ob mo_model initialisiert wurde
        IF mo_model IS INITIAL.
          " Fehlerbehandlung, z.B. Initialisieren von mo_model oder Ausgabe einer Fehlermeldung
          RAISE EXCEPTION TYPE cx_sy_ref_is_initial.
        ENDIF.

        " Holt sich die Daten aus der Model-Klasse
        ls_table = mo_model->get_single_table( iv_id = iv_table_id ).

        " Prüfen, ob der Datensatz gefunden wurde
        IF ls_table IS NOT INITIAL.
          " Statuscode auf 200 OK setzen, da Datensatz gefunden wurde
          mo_response->set_status( iv_status = 200 ).
          " Den gefundenen Datensatz als JSON serialisieren und als Antwort setzen
          mo_response->get_entity( )->set_string_data( /ui2/cl_json=>serialize(
              data        = ls_table
              compress    = abap_true
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          ) ).
        ELSE.
          " Statuscode auf 404 Not Found setzen, da kein Datensatz gefunden wurde
          mo_response->set_status( iv_status = 404 iv_reason_phrase = 'Entry not found' ).
        ENDIF.

        " Den Content-Type der Antwort auf application/json setzen
        mo_response->get_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).

      CATCH cx_sy_ref_is_initial INTO DATA(lx_ref_init).
        " Fehlerbehandlung, wenn Objektreferenz initial ist
        " Setze z.B. einen Fehlerstatus
        mo_response->set_status( iv_status = 500 iv_reason_phrase = 'Internal Server Error' ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

