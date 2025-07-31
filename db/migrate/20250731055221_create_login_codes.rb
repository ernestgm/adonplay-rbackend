class CreateLoginCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :login_codes do |t|
      # Identificador único del dispositivo (ej. Android ID, UUID).
      # Indexado para búsquedas eficientes.
      t.string :device_id, null: false, index: true

      # El código de emparejamiento generado por el backend.
      # DEBE ser único para evitar colisiones y está indexado para búsquedas rápidas.
      t.string :code, null: false, index: { unique: true }

      # ID del usuario que inició la solicitud de emparejamiento desde la web.
      # NO es nulo porque el usuario ya está autenticado al generar el código.
      # Se crea como clave foránea con 'on_delete: :cascade'.
      t.references :user, null: true, foreign_key: true

      t.timestamps # Agrega las columnas created_at y updated_at
    end
  end
end
