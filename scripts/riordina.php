<?php
// Elenchi delle estensioni di file per ciascuna categoria
$img = array("png", "jpg", "webp", "svg");
$ark = array("zip", "tar", "rar", "7z", "gz");
$docs = array("pdf", "txt", "doc", "docx", "pptx", "ppt", "odt", "odp");
$video = array("mp4", "mkv", "webm", "avi", "mov", "flv");
$music = array("mp3", "wav", "ogg");
$app = array("rpm","AppImage");

$directory = readline("Directory: ");
echo ($directory);
$files = scandir($directory);

foreach ($files as $file) {
    if ($file !== '.' && $file !== '..') {
        $extension = pathinfo($file, PATHINFO_EXTENSION);
        $source = $directory . "/" . $file;

        // Inizializzare la variabile di destinazione come vuota
        $destination = "";

        // Controllare l'estensione del file e impostare la destinazione appropriata
        if (in_array($extension, $img)) {
            $destination = "/home/mark/Pictures/" . $file;
        } elseif (in_array($extension, $ark)) {
            $destination = "/home/mark/Downloads/Ark/" . $file;
        } elseif (in_array($extension, $docs)) {
            $destination = "/home/mark/Documents/" . $file;
        } elseif (in_array($extension, $video)) {
            $destination = "/home/mark/Videos/" . $file;
        } elseif (in_array($extension, $music)) {
            $destination = "/home/mark/Music/" . $file;
        } elseif (in_array($extension, $app)) {
            $destination = "/home/mark/appimage-rpm-build" . $file;
        }

        // Se la destinazione è impostata, sposta il file
        if ($destination !== "") {
            // Puoi usare rename() o move_uploaded_file() per spostare il file
            if (rename($source, $destination)) {
                echo "File $file spostato con successo in $destination\n";
            } else {
                echo "Errore nello spostamento del file $file\n";
            }
        }
    }
}
