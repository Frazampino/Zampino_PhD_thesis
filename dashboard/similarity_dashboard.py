import streamlit as st
import pandas as pd
import base64
import xml.etree.ElementTree as ET
from sentence_transformers import SentenceTransformer, util
from streamlit.components.v1 import html

# =========================================================
# BPMN VISUALIZATION USING BPMN-JS
# =========================================================
def display_bpmn_js(bpmn_xml_content: str, container_id: str):
    if not bpmn_xml_content:
        st.markdown(
            f"""
            <div style="border: 2px dashed #999; padding: 20px; height: 300px;
            text-align: center; display: flex; align-items: center;
            justify-content: center; background-color: #f0f2f6;">
                Carica il file BPMN.
            </div>
            """,
            unsafe_allow_html=True
        )
        return

    encoded_xml = base64.b64encode(bpmn_xml_content.encode("utf-8")).decode("utf-8")
    html_code = f"""
    <div id="{container_id}" style="width: 100%; height: 350px; border: 1px solid #ccc;"></div>
    <script src="https://unpkg.com/bpmn-js@17.0.0/dist/bpmn-viewer.development.js"></script>
    <script>
        var viewer = new BpmnJS({{ container: '#{container_id}' }});
        var bpmnXML = atob('{encoded_xml}');
        viewer.importXML(bpmnXML)
            .then(function() {{
                viewer.get('canvas').zoom('fit-viewport');
            }})
            .catch(function(err) {{
                document.getElementById('{container_id}').innerHTML =
                    '<p style="color:red;">Errore nel caricamento del diagramma BPMN.</p>';
            }});
    </script>
    """
    html(html_code, height=380, scrolling=False)


# =========================================================
# BPMN PARSER – EXTRACT ACTIVITIES
# =========================================================
def extract_activities(bpmn_content):
    if not bpmn_content:
        return []

    ns = {'bpmn': 'http://www.omg.org/spec/BPMN/20100524/MODEL'}
    root = ET.fromstring(bpmn_content)

    # Estrae tutte le attività BPMN
    activity_nodes = root.findall(".//bpmn:task", ns)

    activities = [
        elem.attrib.get("name", elem.attrib.get("id"))
        for elem in activity_nodes
    ]

    return activities


# =========================================================
# SIMILARITY COMPUTATION
# =========================================================
model = SentenceTransformer("all-MiniLM-L6-v2")

def calculate_model_similarity(bpmn1, bpmn2):
    tasks1 = extract_activities(bpmn1)
    tasks2 = extract_activities(bpmn2)

    # --- SEMANTIC SIMILARITY ---
    if tasks1 and tasks2:
        emb1 = model.encode(tasks1, convert_to_tensor=True)
        emb2 = model.encode(tasks2, convert_to_tensor=True)
        cosine_scores = util.cos_sim(emb1, emb2)
        sem_sim = float(cosine_scores.mean())
    else:
        sem_sim = 0.0

    # --- STRUCTURAL SIMILARITY ---
    set1, set2 = set(tasks1), set(tasks2)

    if set1 or set2:
        str_sim = len(set1 & set2) / max(len(set1 | set2), 1)
    else:
        str_sim = 0.0

    # --- BEHAVIORAL SIMILARITY (PLACEHOLDER) ---
    beh_sim = str_sim  # può essere migliorato con analisi dei flussi

    # --- GLOBAL SCORE ---
    global_score = (sem_sim + str_sim + beh_sim) / 3

    conformance_results = {
        "Number of tasks in As-Is": len(tasks1),
        "Number of tasks in To-Be": len(tasks2),
        "Matching tasks": len(set1 & set2)
    }

    return conformance_results, str_sim, sem_sim, beh_sim, global_score


# =========================================================
# STREAMLIT UI
# =========================================================
st.set_page_config(layout="wide", page_title="Model Similarity Dashboard")

st.title("🔍 Process Model Similarity Explorer")
st.caption("Process analysis between BPMN")
st.write("---")

col_as_is, col_score, col_to_be = st.columns([4,2,4])

# ---------------------------------------------------------
# AS-IS MODEL
# ---------------------------------------------------------
with col_as_is:
    st.subheader("Model As-Is")
    file_as_is = st.file_uploader("Model upload(BPMN/XML)", type=["bpmn", "xml"], key="as_is")

    content_as_is = file_as_is.getvalue().decode("utf-8") if file_as_is else None
    display_bpmn_js(content_as_is, "canvas_as_is")


# ---------------------------------------------------------
# TO-BE MODEL
# ---------------------------------------------------------
with col_to_be:
    st.subheader("Model To-Be")
    file_to_be = st.file_uploader("Model upload(BPMN/XML)", type=["bpmn", "xml"], key="to_be")

    content_to_be = file_to_be.getvalue().decode("utf-8") if file_to_be else None
    display_bpmn_js(content_to_be, "canvas_to_be")


# ---------------------------------------------------------
# RESULTS COLUMN
# ---------------------------------------------------------
with col_score:
    st.header("Results comparison")

    if content_as_is and content_to_be:
        st.info("Measuring similarity...")

        conf_res, str_sim, sem_sim, beh_sim, total_score = calculate_model_similarity(
            content_as_is, content_to_be
        )

        # --- Conformance ---
        st.markdown("### ✔️ Conformance Summary")
        df_conf = pd.DataFrame(conf_res.items(), columns=["Metrics", "Value"]).set_index("Metrics")
        st.table(df_conf)

        # --- Similarità ---
        st.markdown("### Similarity Metrics")
        df_sim = pd.DataFrame({
            "Metrics": ["Structural", "Semantic", "Behavioral"],
            "Score": [f"{str_sim:.2f}", f"{sem_sim:.2f}", f"{beh_sim:.2f}"]
        }).set_index("Metrics")
        st.table(df_sim)

        # --- Total Score ---
        st.markdown("### Global score")
        color = "green" if total_score > 0.8 else "orange"
        st.markdown(
            f"<h2 style='color:{color}; text-align:center;'>{total_score*100:.0f}%</h2>",
            unsafe_allow_html=True
        )

    else:
        st.info("Upload both BPMN model to reach a similarity comparison.")

st.write("---")
st.markdown("💡 *Nota: Similarity measured through SentenceTransformer.*")

