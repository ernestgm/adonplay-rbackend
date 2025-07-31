class CreateDevicesVerifyCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :devices_verify_codes do |t|
      # Identificador único del dispositivo (ej. Android ID, UUID).
      # Indexado para búsquedas eficientes.
      t.string :device_id, null: false, index: true

      # El código de emparejamiento generado por el backend.
      # DEBE ser único para evitar colisiones y está indexado para búsquedas rápidas.
      t.string :code, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
