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
            """
            <div style="border: 2px dashed #999; padding: 20px; height: 300px;
            text-align: center; display: flex; align-items: center;
            justify-content: center; background-color: #f0f2f6;">
                Upload BPMN file
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
                    '<p style="color:red;">Error loading BPMN diagram.</p>';
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
    activity_nodes = root.findall(".//bpmn:task", ns)

    activities = [
        elem.attrib.get("name", elem.attrib.get("id"))
        for elem in activity_nodes
    ]
    return activities

# =========================================================
# BEHAVIORAL SIMILARITY – TAR
# =========================================================
def compute_TAR_similarity(tasks1, tasks2):
    TAR1 = {(tasks1[i], tasks1[i+1]) for i in range(len(tasks1)-1)}
    TAR2 = {(tasks2[i], tasks2[i+1]) for i in range(len(tasks2)-1)}

    intersection = TAR1 & TAR2
    union = TAR1 | TAR2
    similarity = len(intersection) / max(len(union), 1)

    only_in_1 = TAR1 - TAR2
    only_in_2 = TAR2 - TAR1

    return similarity, only_in_1, only_in_2

# =========================================================
# LOAD SEMANTIC MODEL
# =========================================================
model = SentenceTransformer("all-MiniLM-L6-v2")

# =========================================================
# SIMILARITY COMPUTATION
# =========================================================
def calculate_model_similarity(bpmn1, bpmn2):

    tasks1 = extract_activities(bpmn1)
    tasks2 = extract_activities(bpmn2)

    set1, set2 = set(tasks1), set(tasks2)

    # --- STRUCTURAL SIMILARITY ---
    str_sim = len(set1 & set2) / max(len(set1 | set2), 1) if (set1 or set2) else 0.0

    # --- SEMANTIC SIMILARITY ---
    if tasks1 and tasks2:
        emb1 = model.encode(tasks1, convert_to_tensor=True)
        emb2 = model.encode(tasks2, convert_to_tensor=True)
        cosine_scores = util.cos_sim(emb1, emb2)
        sem_sim = float(cosine_scores.mean())
    else:
        sem_sim = 0.0

    # --- BEHAVIORAL SIMILARITY ---
    beh_sim, tar_only_1, tar_only_2 = compute_TAR_similarity(tasks1, tasks2)

    # --- GLOBAL SCORE PONDERATA ---
    # Definiamo i pesi (somma = 1)
    weights = {
        "Structural": 0.3,
        "Semantic": 0.4,
        "Behavioral": 0.3
    }
    global_score = (
        str_sim * weights["Structural"] +
        sem_sim * weights["Semantic"] +
        beh_sim * weights["Behavioral"]
    )

    # --- CONFORMANCE ---
    conformance_results = {
        "Number of tasks in As-Is": len(tasks1),
        "Number of tasks in To-Be": len(tasks2),
        "Matching tasks": len(set1 & set2)
    }

    # --- CONFLICT PATTERNS ---
    only_in_as_is = list(set1 - set2)
    only_in_to_be = list(set2 - set1)

    return (
        conformance_results,
        str_sim,
        sem_sim,
        beh_sim,
        global_score,
        only_in_as_is,
        only_in_to_be,
        tar_only_1,
        tar_only_2,
        weights
    )

# =========================================================
# STREAMLIT UI
# =========================================================
st.set_page_config(layout="wide", page_title="Process Model Similarity Explorer")

st.title("🔍 Process Model Similarity Explorer")
st.caption("Process analysis between BPMN models")
st.write("---")

col_as_is, col_score, col_to_be = st.columns([4,3,4])

# AS-IS
with col_as_is:
    st.subheader("Model As-Is")
    file_as_is = st.file_uploader("Upload BPMN/XML", type=["bpmn", "xml"], key="as_is")
    content_as_is = file_as_is.getvalue().decode("utf-8") if file_as_is else None
    display_bpmn_js(content_as_is, "canvas_as_is")

# TO-BE
with col_to_be:
    st.subheader("Model To-Be")
    file_to_be = st.file_uploader("Upload BPMN/XML", type=["bpmn", "xml"], key="to_be")
    content_to_be = file_to_be.getvalue().decode("utf-8") if file_to_be else None
    display_bpmn_js(content_to_be, "canvas_to_be")

# RESULTS
with col_score:
    st.header("Results comparison")

    if content_as_is and content_to_be:

        st.info("Measuring similarity...")

        (
            conf_res,
            str_sim,
            sem_sim,
            beh_sim,
            total_score,
            only_in_as_is,
            only_in_to_be,
            tar_only_1,
            tar_only_2,
            weights
        ) = calculate_model_similarity(content_as_is, content_to_be)

        # --- Conformance Summary ---
        st.markdown("### ✔️ Conformance Summary")
        df_conf = pd.DataFrame(conf_res.items(), columns=["Metric", "Value"]).set_index("Metric")
        st.table(df_conf)

        # --- Similarity Weights Table ---
        st.subheader("📊 Similarity Weights and Scores")
        weights_df = pd.DataFrame({
            "Similarity Type": ["Structural", "Semantic", "Behavioral"],
            "Score": [str_sim, sem_sim, beh_sim],
            "Weight": [weights["Structural"], weights["Semantic"], weights["Behavioral"]]
        })
        st.table(weights_df.style.format({"Score": "{:.2f}", "Weight": "{:.2f}"}))

        # --- Global Score ---
        st.markdown("### 🌍 Global Score (Weighted)")
        color = "green" if total_score > 0.8 else "orange"
        st.markdown(
            f"<h2 style='color:{color}; text-align:center;'>{total_score*100:.0f}%</h2>",
            unsafe_allow_html=True
        )

        # --- Conflict Patterns Scrollable ---
        st.markdown("### ⚠️ Conflict Patterns")

        def display_scrollable_list(title, items, color="error"):
            if items:
                if color=="error":
                    st.error(title)
                elif color=="warning":
                    st.warning(title)
                else:
                    st.info(title)

                st.markdown(
                    f"""
                    <div style='max-height:200px; overflow:auto; border:1px solid #ccc; padding:5px; background:#f9f9f9'>
                        {''.join(f'<p style="margin:2px 0;">{item}</p>' for item in items)}
                    </div>
                    """,
                    unsafe_allow_html=True
                )

        display_scrollable_list("Tasks only in As-Is", only_in_as_is, "error")
        display_scrollable_list("Tasks only in To-Be", only_in_to_be, "error")
        display_scrollable_list("Behavioral patterns only in As-Is (TAR)", list(tar_only_1), "warning")
        display_scrollable_list("Behavioral patterns only in To-Be (TAR)", list(tar_only_2), "warning")

    else:
        st.info("Upload both BPMN models to perform similarity analysis.")

st.write("---")
st.markdown("💡 Similarity measured via Structural overlap, SentenceTransformer semantic similarity, and TAR behavioral comparison. Global score is weighted based on predefined weights.")
