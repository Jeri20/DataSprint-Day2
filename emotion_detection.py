import cv2
from fer import FER
import json
import pyrender
import trimesh
import numpy as np
from PIL import Image
import io

# ==============================
# Load Spider Model (Trimesh + Pyrender)
# ==============================
def load_spider_model(path="Wolf_spider.glb"):
    mesh = trimesh.load(path)
    scene = pyrender.Scene()

    if isinstance(mesh, trimesh.Scene):
        for name, geom in mesh.geometry.items():
            mesh_node = pyrender.Mesh.from_trimesh(geom)
            scene.add(mesh_node)
    else:
        mesh_node = pyrender.Mesh.from_trimesh(mesh)
        scene.add(mesh_node)

    # Add directional light
    light = pyrender.DirectionalLight(color=np.ones(3), intensity=3.0)
    scene.add(light)

    return scene

# ==============================
# Render Spider
# ==============================
def render_spider(renderer, scene, scale=1.0, model_path="Wolf_spider.glb"):
    try:
        # Try OpenGL
        color, _ = renderer.render(scene)
        return color
    except Exception as e:
        print("⚠️ OpenGL failed, fallback to Trimesh:", e)
        # Fallback: software render using trimesh
        mesh = trimesh.load(model_path)
        if isinstance(mesh, trimesh.Scene):
            tm_scene = mesh
        else:
            tm_scene = trimesh.Scene(mesh)

        png = tm_scene.save_image(resolution=(256,256))
        color = np.array(Image.open(io.BytesIO(png)))
        return color

# ==============================
# Overlay RGBA spider onto BGR webcam
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
# Main Loop
# ==============================
def main():
    cap = cv2.VideoCapture(0)
    detector = FER(mtcnn=True)

    spider_scene = load_spider_model("Wolf_spider.glb")
    renderer = pyrender.OffscreenRenderer(300,300)
    spider_img = render_spider(renderer, spider_scene, scale=0.6)

    print("Emotion detection started... (press 'q' to quit)")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        results = detector.detect_emotions(frame)
        if results:
            (x, y, w, h) = results[0]["box"]
            emotions = results[0]["emotions"]
            dominant = max(emotions, key=emotions.get)

            # Overlay spider above head
            head_x = x + w//2
            head_y = y - 30
            frame = overlay_image(frame, spider_img, head_x, head_y)

            # Save emotion JSON
            with open("D:/ETherapy/etver4/lib/pages/emotion.json","w") as f:
                json.dump({"emotion":dominant, "confidence":emotions[dominant]}, f)

            # Draw box + label
            cv2.rectangle(frame,(x,y),(x+w,y+h),(0,255,0),2)
            cv2.putText(frame, dominant, (x, y-10), cv2.FONT_HERSHEY_SIMPLEX,0.9,(0,255,0),2)

        cv2.imshow("Emotion + Spider", frame)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyAllWindows()
    renderer.delete()

if __name__ == "__main__":
    main()
