<?php
$img = array("png", "jpg", "webp", "svg");
$ark = array("zip", "tar", "rar", "7z", "gz", "tar.xz", "tgz", "xz");
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
        $destination = "";

        if (in_array($extension, $img)) {
            $destination = getenv("HOME") . "/Pictures/" . $file;
        } elseif (in_array($extension, $ark)) {
            $destination = getenv("HOME") . "/Downloads/Ark/" . $file;
        } elseif (in_array($extension, $docs)) {
            $destination = getenv("HOME") . "/Documents/" . $file;
        } elseif (in_array($extension, $video)) {
            $destination = getenv("HOME") . "/Videos/" . $file;
        } elseif (in_array($extension, $music)) {
            $destination = getenv("HOME") . "/Music/" . $file;
        } elseif (in_array($extension, $app)) {
            $destination = getenv("HOME") . "/appimage-rpm-build/" . $file;
        }

        if ($destination !== "") {
            if (rename($source, $destination)) {
                echo "File $file spostato con successo in $destination\n";
            } else {
                echo "Errore nello spostamento del file $file\n";
            }
        }
    }
}
