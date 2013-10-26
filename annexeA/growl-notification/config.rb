sass_dir = "."
css_dir  = "."

# Utilisation du système de notifications Growl lorsque la gem
# ruby_gntp est disponible. Aucune erreur ne sera émise par Ruby
# sur les systèmes qui en sont dépourvu.
begin
  require "ruby_gntp"

  # Définition des attributs communs aux notifications.
  # Important :
  # Utilisez si possible le même :app_name entre tous vos projets.
  # Chaque nouveau nom ajoute une entrée dans l'onglet Applications
  # de Growl.
  growl_data = {
    :app_name => "Compass",
    # Personnalisez le chemin de l'icône de la notification à afficher.
    # Ici, l'icône compass_icon.png est située au même niveau que le
    # fichier de configuration.
    :icon => "#{File.expand_path('./compass_icon.png')}",
  }

  # Affichage d'une notification Growl lorsqu'une feuille de styles
  # est sauvegardée sur le disque.
  on_stylesheet_saved do |filename|
    GNTP.notify(growl_data.clone.merge({
      :title    => "Mise à jour d'une CSS",
      :text     => "#{File.basename(filename)}",
    }))
  end

  # Affichage d'une notification Growl lorsqu'une erreur de compilation
  # est survenue.
  on_stylesheet_error do |filename, message|
    GNTP.notify(growl_data.clone.merge({
      :title    => "Erreur de compilation",
      :text     => "#{File.basename(filename)}: #{message}",
      :sticky   => true, # La notification sera persistante
    }))
  end

  # Affichage d'une notification Growl lorsqu'une sprite map
  # est sauvegardée sur le disque.
  on_sprite_saved do |filename|
    GNTP.notify(growl_data.clone.merge({
      :title    => "Sprite sauvegardé",
      :text     => "#{File.basename(filename)}",
    }))
  end
rescue LoadError
end
