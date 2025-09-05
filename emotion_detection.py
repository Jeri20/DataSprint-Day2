import cv2
from fer import FER
import json
import trimesh
import numpy as np
from PIL import Image
import io

# ==============================
# Load spider as static RGBA frame
# ==============================
def load_spider_image(path="animated_spider.glb", size=(128,128)):
    mesh = trimesh.load(path)
    if isinstance(mesh, trimesh.Scene):
        scene = mesh
    else:
        scene = trimesh.Scene(mesh)
    png = scene.save_image(resolution=size)
    img = np.array(Image.open(io.BytesIO(png)))
    return img

# ==============================
# Overlay RGBA spider onto webcam
# ==============================
def overlay_image(bg, overlay, x, y):
    h, w, _ = overlay.shape
    y1, y2 = max(0, y-h), min(bg.shape[0], y)
    x1, x2 = max(0, x-w//2), min(bg.shape[1], x+w//2)

    overlay_crop = overlay[-(y-y1):, -(x+w//2-x2):, :]
    oh, ow, _ = overlay_crop.shape
    roi = bg[y1:y1+oh, x1:x1+ow]

    if overlay_crop.shape[2] == 4:  # RGBA
        alpha = overlay_crop[:,:,3:]/255.0
        roi[:] = (1-alpha)*roi + alpha*overlay_crop[:,:,:3]
    else:
        roi[:] = overlay_crop

    return bg

# ==============================
# Main loop
# ==============================
def main():
    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    detector = FER(mtcnn=True)

    spider_img = load_spider_image("animated_spider.glb", size=(128,128))
    spider_x, spider_y = 100, 100
    dx, dy = 2, 1

    print("Press 'q' to quit")
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame")
            break

        # Detect emotions
        results = detector.detect_emotions(frame)
        if results:
            (x, y, w, h) = results[0]["box"]
            emotions = results[0]["emotions"]
            dominant = max(emotions, key=emotions.get)

            # Save emotion JSON
            with open("D:/ETherapy/etver4/lib/pages/emotion.json", "w") as f:
                json.dump({"emotion": dominant, "confidence": emotions[dominant]}, f)

            # Draw box + label
            cv2.rectangle(frame, (x,y), (x+w,y+h), (0,255,0), 2)
            cv2.putText(frame, dominant, (x, y-10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0,255,0), 2)

            # Make spider follow head
            spider_x = x + w//2
            spider_y = y - 30

        # Animate spider crawling slightly
        spider_x += dx
        spider_y += dy
        if spider_x < 0 or spider_x > frame.shape[1]-128: dx *= -1
        if spider_y < 0 or spider_y > frame.shape[0]-128: dy *= -1

        frame = overlay_image(frame, spider_img, spider_x, spider_y)
        cv2.imshow("Crawling Spider + Emotion", frame)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
