# RVC All in One

This Docker image is designed to facilitate the deployment and execution of the [Retrieval-based Voice Conversion WebUI](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) project. It includes all the necessary dependencies, pre-trained models, and services, including TensorBoard for monitoring.

Additionally, FileBrowser is integrated into this image to provide a file management interface, making it easier to manage datasets and files within the container.

## Purpose

The primary goal of this Docker image is to provide an easy-to-use environment for running the Retrieval-based Voice Conversion WebUI project, allowing users to convert voices using a web-based interface. The inclusion of TensorBoard enables users to visualize and monitor the training and conversion processes effectively, while FileBrowser simplifies file management tasks.

## Volumes

The Docker image is configured with the following volumes to persist data across container restarts and share data between the host and the container:

- `/app/weights`: This volume is used to store the model weights.
- `/app/logs`: This volume is used to store log files, which can be visualized using TensorBoard.
- `/app/audio`: This volume is used to store audio files.
- `/app/dataset`: This volume is available for dataset storage and management through FileBrowser.

## Dataset Location

Place your datasets and other files in the directories `/dataset` within the `/app` directory in the container using FileBrowser. Follow the project's documentation for organizing and using the datasets.

## Usage

1. **Pull the Docker Image**

   ```sh
   docker pull pinkfloyd1213/rvc-all-in-one:latest
   ```

2. **Run the Docker Container**

   ```sh
   docker run -d \
     -p 7865:7865 \
     -p 6006:6006 \
     -p 8080:8080 \ 
     -v /path/to/weights:/app/assets/weights \
     -v /path/to/logs:/app/logs \
     -v /path/to/audio:/app/audio \
     -v /path/to/dataset:/app/dataset \
     pinkfloyd1213/rvc-all-in-one:latest
   ```

   Replace `/path/to/weights`, `/path/to/logs`, `/path/to/audio`, and `/path/to/dataset` with the paths to the corresponding directories on your host machine.

3. **Access the WebUI**

   Open a web browser and navigate to `http://localhost:7865` to access the Voice Conversion WebUI.

4. **Access TensorBoard**

   Open a web browser and navigate to `http://localhost:6006` to access TensorBoard.

5. **Access FileBrowser**

   Open a web browser and navigate to `http://localhost:8080` to access FileBrowser for file management. The default login is `admin` for the username and `admin` for the password.

6. **Stop and Remove the Docker Container**

   ```sh
   docker stop <container-id>
   docker rm <container-id>
   ```

   Replace `<container-id>` with the ID of the running Docker container.

## Additional Information

For additional information and details on the Retrieval-based Voice Conversion project, refer to the [official GitHub repository](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI).

You can build this image yourself, for that, go check the GitHub's project: [Github repository](https://github.com/PinkFloyd1213/RVC-All-In-One)
