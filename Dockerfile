# syntax=docker/dockerfile:1

FROM ubuntu:22.04

# Cloner le dépôt GitHub
RUN apt update && apt install -y git
RUN git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git /app

WORKDIR /app

# Exposer les ports nécessaires
EXPOSE 7865 
EXPOSE 6006 
EXPOSE 8080 

# Installer les dépendances système et Python
RUN apt install -y -qq python3.10 python3-pip python3.10-venv wget
RUN apt install -y -qq ffmpeg aria2 unzip
RUN pip3 install -r requirements.txt
RUN pip3 install tensorboard

# Télécharger les modèles pré-entraînés
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/pretrained_v2/D40k.pth -d assets/pretrained_v2/ -o D40k.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/pretrained_v2/G40k.pth -d assets/pretrained_v2/ -o G40k.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/pretrained_v2/f0D40k.pth -d assets/pretrained_v2/ -o f0D40k.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/pretrained_v2/f0G40k.pth -d assets/pretrained_v2/ -o f0G40k.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/uvr5_weights/HP2-人声vocals+非人声instrumentals.pth -d assets/uvr5_weights/ -o HP2-人声vocals+非人声instrumentals.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/uvr5_weights/HP5-主旋律人声vocals+其他instrumentals.pth -d assets/uvr5_weights/ -o HP5-主旋律人声vocals+其他instrumentals.pth
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/hubert_base.pt -d assets/hubert -o hubert_base.pt
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lj1995/VoiceConversionWebUI/resolve/main/rmvpe.pt -d assets/hubert -o rmvpe.pt


# Modifier les chemins et les chaînes de caractères dans infer-web.py
RUN sed -i 's|E:\\\\codes\\\\py39\\\\test-20230416b\\\\todo-songs\\\\冬之花clip1.wav|/app/audio/clip.wav|g' /app/infer-web.py \
 && sed -i 's|E:\\\\codes\\\\py39\\\\test-20230416b\\\\todo-songs|/app/audio|g' /app/infer-web.py \
 && sed -i 's|也可批量输入音频文件, 二选一, 优先读文件夹|Audio files can also be imported in batch, with one of two options, prioritizing folders for reading.|g' /app/infer-web.py \
 && sed -i 's|E:\\\\codes\\\\py39\\\\test-20230416b\\\\todo-songs\\\\todo-songs|/app/audio/|g' /app/infer-web.py \
 && sed -i 's|E:\\\\语音音频+标注\\\\米津玄师\\\\src|/app/dataset|g' /app/infer-web.py \
 && sed -i 's|选择音高提取算法:输入歌声可用pm提速,高质量语音但CPU差可用dio提速,harvest质量更好但慢,rmvpe效果最好且微吃CPU/GPU|Select pitch extraction algorithm: input song can be speeded up by pm, high quality voice but poor CPU can be speeded up by dio, harvest is better but slower, rmvpe is the best and slightly eats CPU/GPU.|g' /app/infer-web.py \
 && sed -i 's|assets/pretrained_v2/f0G40k.pth|/app/assets/pretrained_v2/f0G40k.pth|g' /app/infer-web.py \
 && sed -i 's|E:\\\\codes\\\\py39\\\\logs\\\\mi-test_f0_48k\\\\G_23333.pth|/app/logs/model/G_23333.pth|g' /app/infer-web.py

# Modifier les chemins dans infer/lib/rmvpe.py
RUN sed -i 's|C:\\\\Users\\\\liujing04\\\\Desktop\\\\Z\\\\冬之花clip1.wav|/app/audio/file.wav|g' /app/infer/lib/rmvpe.py

# Modifier les chemins dans tools/infer/infer-pm-index256.py
RUN sed -i 's|todo-songs/%s|/app/audio/%s|g' /app/tools/infer/infer-pm-index256.py


# Installer FileBrowser
RUN wget https://github.com/filebrowser/filebrowser/releases/download/v2.0.16/linux-amd64-filebrowser.tar.gz \
 && tar -xzvf linux-amd64-filebrowser.tar.gz \
 && mv filebrowser /usr/local/bin/

# Configurer FileBrowser pour pointer vers /app et démarrer sur le port 8080
RUN filebrowser -r /app -p 8080 -a 0.0.0.0 -d /config/filebrowser.db config init \
 && filebrowser -d /config/filebrowser.db users add admin admin --perm.admin

# Définir les volumes
VOLUME [ "/app/assets/weights", "/app/logs", "/app/audio", "/app/dataset" ]

# Créer le script entrypoint.sh
RUN echo "#!/bin/bash" > /app/entrypoint.sh \
 && echo "" >> /app/entrypoint.sh \
 && echo "# Démarrer FileBrowser en arrière-plan" >> /app/entrypoint.sh \
 && echo "filebrowser -r /app -p 8080 -d /config/filebrowser.db &" >> /app/entrypoint.sh \
 && echo "" >> /app/entrypoint.sh \
 && echo "# Exécuter votre script Python" >> /app/entrypoint.sh \
 && echo "python3 infer-web.py &" >> /app/entrypoint.sh \
 && echo "" >> /app/entrypoint.sh \
 && echo "# Exécuter TensorBoard en arrière-plan" >> /app/entrypoint.sh \
 && echo "tensorboard --logdir /app/logs --bind_all" >> /app/entrypoint.sh \
 && chmod +x /app/entrypoint.sh

# Définir la commande par défaut
CMD ["/app/entrypoint.sh"]
