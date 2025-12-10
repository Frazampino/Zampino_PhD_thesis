import streamlit as st
import pandas as pd
import base64
import xml.etree.ElementTree as ET
from sentence_transformers import SentenceTransformer, util
from streamlit.components.v1 import html

# --- Funzione per visualizzare BPMN usando HTML/JS ---
def display_bpmn_js(bpmn_xml_content: str, container_id: str):
    if not bpmn_xml_content:
        st.markdown(
            f"""
            <div style="border: 2px dashed #999; padding: 20px; height: 300px; text-align: center; display: flex; align-items: center; justify-content: center; background-color: #f0f2f6;">
                Carica il file BPMN.
            </div>
            """, unsafe_allow_html=True
        )
        return

    encoded_xml = base64.b64encode(bpmn_xml_content.encode('utf-8')).decode('utf-8')
    html_code = f"""
    <div id="{container_id}"></div>
    <script src="https://unpkg.com/bpmn-js@17.0.0/dist/bpmn-viewer.development.js"></script>
    <script>
      var viewer = new BpmnJS({{ container: '#{container_id}' }});
      var bpmnXML = atob('{encoded_xml}');
      viewer.importXML(bpmnXML)
        .then(function() {{
            viewer.get('canvas').zoom('fit-viewport');
        }})
        .catch(function(err) {{
            document.getElementById('{container_id}').innerHTML = '<p style="color: red;">Errore nel caricamento del diagramma BPMN.</p>';
        }});
    </script>
    """
    html(html_code, height=350, scrolling=False)

# --- Parsing BPMN ---
def extract_activities(bpmn_content):
    if not bpmn_content:
        return []
    ns = {'bpmn': 'http://www.omg.org/spec/BPMN/20100524/MODEL'}
    root = ET.fromstring(bpmn_content)
    activities = [elem.attrib.get('name', elem.attrib.get('id')) 
                  for elem in root.findall(".//bpmn:task", ns)]
    return activities

# --- Calcolo Similarità ---
model = SentenceTransformer('all-MiniLM-L6-v2')  # modello leggero e veloce

def calculate_model_similarity(bpmn1, bpmn2):
    tasks1 = extract_activities(bpmn1)
    tasks2 = extract_activities(bpmn2)
    
    # --- Similarità semantica ---
    if tasks1 and tasks2:
        embeddings1 = model.encode(tasks1, convert_to_tensor=True)
        embeddings2 = model.encode(tasks2, convert_to_tensor=True)
        cosine_scores = util.cos_sim(embeddings1, embeddings2)
        sem_sim = float(cosine_scores.mean())
    else:
        sem_sim = 0.0

    # --- Similarità strutturale semplice ---
    set1, set2 = set(tasks1), set(tasks2)
    if set1 or set2:
        str_sim = len(set1 & set2) / max(len(set1 | set2), 1)
    else:
        str_sim = 0.0

    # --- Behavioral similarity placeholder (da migliorare) ---
    beh_sim = str_sim  # come proxy
    
    global_score = (sem_sim + str_sim + beh_sim) / 3

    conformance_results = {
        'Number of tasks in As-Is': len(tasks1),
        'Number of tasks in To-Be': len(tasks2),
        'Matching tasks': len(set1 & set2)
    }

    return conformance_results, str_sim, sem_sim, beh_sim, global_score

# --- Streamlit UI ---
st.set_page_config(layout="wide", page_title="Model Similarity Dashboard")
st.title("Model-to-Model Similarity Dashboard")
st.caption("Analisi prototipale dei processi BPMN")
st.write("---")

col_as_is, col_score, col_to_be = st.columns([4,2,4])

with col_as_is:
    st.subheader("Modello As-Is")
    file_as_is = st.file_uploader("Carica Modello 'As-Is' (BPMN/XML)", type=['bpmn', 'xml'], key="as_is")
    model_content_as_is = file_as_is.getvalue().decode("utf-8") if file_as_is else None
    display_bpmn_js(model_content_as_is, "canvas_as_is")

with col_to_be:
    st.subheader("Modello To-Be")
    file_to_be = st.file_uploader("Carica Modello 'To-Be' (BPMN/XML)", type=['bpmn', 'xml'], key="to_be")
    model_content_to_be = file_to_be.getvalue().decode("utf-8") if file_to_be else None
    display_bpmn_js(model_content_to_be, "canvas_to_be")

with col_score:
    st.header("Risultati Confronto")
    if model_content_as_is and model_content_to_be:
        st.info("Calcolando similarità...")
        conf_res, str_sim, sem_sim, beh_sim, total_score = calculate_model_similarity(
            model_content_as_is, model_content_to_be
        )

        st.markdown("##### Conformance")
        df_conf = pd.DataFrame(conf_res.items(), columns=['Metriche','Valore']).set_index('Metriche')
        st.table(df_conf)

        st.markdown("##### Similarità")
        df_sim = pd.DataFrame({
            'Metriche': ['Structural', 'Semantic', 'Behavioral'],
            'Punteggio': [f"{str_sim:.2f}", f"{sem_sim:.2f}", f"{beh_sim:.2f}"]
        }).set_index('Metriche')
        st.table(df_sim)

        st.markdown("##### Punteggio Globale")
        st.markdown(f"**Total Score:** **<span style='font-size:24px; color:{'green' if total_score>0.7 else 'orange'}'>{total_score*100:.0f}%</span>**", unsafe_allow_html=True)
    else:
        st.info("Carica entrambi i modelli BPMN per visualizzare il confronto.")

st.markdown("---")
st.markdown("💡 *Nota: Similarità semantica calcolata tramite embeddings; similarità strutturale basata su matching semplice delle attività.*")
