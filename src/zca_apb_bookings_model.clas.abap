CLASS zca_apb_bookings_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Definiert eine Tabelle von Buchungen.
    TYPES: tt_bookings TYPE STANDARD TABLE OF zca_apb_booking WITH DEFAULT KEY.

    " Methoden zur Interaktion mit Buchungsdaten.
    METHODS:
      " Gibt alle Buchungen zurück.
      get_all_bookings
        RETURNING VALUE(rt_bookings) TYPE tt_bookings,

      " Gibt Buchungen für ein spezifisches Datum zurück.
      get_bookings_by_date
        IMPORTING !iv_date                   TYPE zca_apb_booking-datum
        RETURNING VALUE(rt_bookings_by_date) TYPE tt_bookings,

      get_bookings_by_id
        IMPORTING !iv_id                   TYPE zca_apb_booking-id
        RETURNING VALUE(rt_bookings_by_id) TYPE tt_bookings,

      " Erstellt eine Buchung basierend auf dem übergebenen JSON-String.
      create_bookings_by_date
        IMPORTING iv_body_string    TYPE string
        RETURNING VALUE(rv_success) TYPE zca_apb_booking
        RAISING   cx_sy_conversion_no_number cx_sy_conversion_error cx_sy_open_sql_db,

      " Löscht eine Buchung basierend auf Datum und Tisch-ID.
      delete_bookings_by_date
        IMPORTING
          iv_reservations_id       TYPE zca_apb_booking-id
        RETURNING
          VALUE(rv_success)        TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zca_apb_bookings_model IMPLEMENTATION.
  METHOD get_all_bookings.
    " Liest alle Buchungsdaten aus der Datenbanktabelle.
    SELECT * FROM zca_apb_booking INTO TABLE @rt_bookings.
  ENDMETHOD.

  METHOD get_bookings_by_date.
    " Liest Buchungen für ein spezifisches Datum aus der Datenbanktabelle.
    SELECT * FROM zca_apb_booking INTO TABLE @rt_bookings_by_date WHERE datum = @iv_date.
  ENDMETHOD.

  METHOD get_bookings_by_id.
    SELECT * FROM zca_apb_booking INTO TABLE @rt_bookings_by_id WHERE id = @iv_id.
  ENDMETHOD.

  METHOD create_bookings_by_date.
    " Erstellt eine Buchung basierend auf den Daten im JSON-Format.
    DATA: ls_booking TYPE zca_apb_booking.

    TRY.
        " Deserialisiert den JSON-String zu einem ABAP-Struktur.
        /ui2/cl_json=>deserialize( EXPORTING json = iv_body_string CHANGING data = ls_booking ).
      CATCH cx_sy_conversion_no_number cx_sy_conversion_error.
        " Wirft Fehler bei Konvertierungsproblemen.
    ENDTRY.


    DATA(id) = |{ sy-datum }-{ sy-uzeit }-{ sy-uname }|.
    ls_booking-id = id .

    TRY.
        " Fügt die Buchung in die Datenbank ein.
        INSERT zca_apb_booking FROM ls_booking.
        " Schließt die Transaktion ab und speichert die Änderungen in der Datenbank.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
        rv_success = ls_booking.
      CATCH cx_sy_open_sql_db.
        " Wirft einen Fehler, wenn beim Einfügen in die Datenbank ein Problem auftritt.
    ENDTRY.
  ENDMETHOD.

  METHOD delete_bookings_by_date.
    TRY.
        " Löscht Buchungen basierend auf Datum und Tisch-ID.
        DELETE FROM zca_apb_booking WHERE id = iv_reservations_id.
        " Setzt den Erfolg basierend auf dem Ergebnis der Löschoperation.
        rv_success = abap_true.
      CATCH cx_sy_open_sql_db.
        " Wirft einen Fehler, wenn beim Einfügen in die Datenbank ein Problem auftritt.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
