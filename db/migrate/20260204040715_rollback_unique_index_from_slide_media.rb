class RollbackUniqueIndexFromSlideMedia < ActiveRecord::Migration[8.0]
  def change
    # 1. Eliminamos el índice único anterior
    remove_index :slide_media, column: [:slide_id, :media_id]

    # 2. (Opcional) Creamos un índice normal para mantener el performance
    add_index :slide_media, [:slide_id, :media_id], unique: true
  end
end