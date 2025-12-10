import streamlit as st
import pandas as pd
from streamlit.components.v1 import html
import base64

# --- Funzione per Visualizzare BPMN usando HTML/JS (BPMN.js) ---
def display_bpmn_js(bpmn_xml_content: str, container_id: str):
    """
    Genera e visualizza il diagramma BPMN usando la libreria BPMN.js.
    """
    # Se il contenuto è None o vuoto, non visualizzare nulla
    if not bpmn_xml_content:
        st.markdown(
            f"""
            <div style="border: 2px dashed #999; padding: 20px; height: 300px; text-align: center; display: flex; align-items: center; justify-content: center; background-color: #f0f2f6;">
                Carica il file BPMN.
            </div>
            """, unsafe_allow_html=True
        )
        return

    # Codifica il contenuto XML in base64 per passarlo in sicurezza a JavaScript
    encoded_xml = base64.b64encode(bpmn_xml_content.encode('utf-8')).decode('utf-8')

    html_code = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>BPMN Viewer</title>
      <script src="https://unpkg.com/bpmn-js@17.0.0/dist/bpmn-viewer.development.js"></script>
      <style>
        #{container_id} {{
          height: 300px;
          width: 100%;
          border: 1px solid #ccc;
        }}
      </style>
    </head>
    <body>
      <div id="{container_id}"></div>
      <script>
        var viewer = new BpmnJS({{ container: '#{container_id}' }});
        
        // Decodifica il contenuto XML da base64
        var bpmnXML = atob('{encoded_xml}'); 
        
        viewer.importXML(bpmnXML)
          .then(function(result) {{
            // Funzione opzionale: zoom del diagramma per adattarlo al contenitore
            viewer.get('canvas').zoom('fit-viewport');
          }})
          .catch(function(err) {{
            console.error('could not import BPMN XML', err);
            document.getElementById('{container_id}').innerHTML = '<p style="color: red; padding: 10px;">Errore nel caricamento del diagramma BPMN.</p>';
          }});
      </script>
    </body>
    </html>
    """
    
    # Esegui il codice HTML/JS in Streamlit
    html(html_code, height=350, scrolling=False)


# --- Logica di Calcolo Placeholder ---
def calculate_model_similarity(bpmn_model_1_content, bpmn_model_2_content):
    structural_similarity_score = 0.75 
    semantic_similarity_score = 0.88
    behavioral_similarity_score = 0.65
    global_score = (structural_similarity_score + semantic_similarity_score + behavioral_similarity_score) / 3 
    
    conformance_results = {
        'Synchronization': '✅',
        'Guaranteed termination': '✅',
        'Unique end event execution': '✅',
        'No dead activities': '✅',
        'Structural Score': f"{structural_similarity_score * 100:.0f}%"
    }
    return conformance_results, structural_similarity_score, semantic_similarity_score, behavioral_similarity_score, global_score

# --- Interfaccia Utente Streamlit Aggiornata ---
st.set_page_config(layout="wide", page_title="Model Similarity Dashboard")
st.title("Model-to-Model Similarity Dashboard (Prototipo)")
st.caption("Estensione di Apromore per l'analisi quantitativa dei processi.")
st.write("---")

col_as_is, col_score, col_to_be = st.columns([4, 2, 4])

# Modello As-Is
with col_as_is:
    st.subheader("Modello As-Is")
    file_as_is = st.file_uploader("Carica Modello 'As-Is' (BPMN/XML)", type=['bpmn', 'xml'], key="as_is")
    model_content_as_is = file_as_is.getvalue().decode("utf-8") if file_as_is else None
    display_bpmn_js(model_content_as_is, "canvas_as_is")

# Modello To-Be
with col_to_be:
    st.subheader("Modello To-Be (Reference)")
    file_to_be = st.file_uploader("Carica Modello 'To-Be' (BPMN/XML)", type=['bpmn', 'xml'], key="to_be")
    model_content_to_be = file_to_be.getvalue().decode("utf-8") if file_to_be else None
    display_bpmn_js(model_content_to_be, "canvas_to_be")

# Risultati Confronto
with col_score:
    st.header("Risultati Confronto")
    if model_content_as_is and model_content_to_be:
        st.success("Analisi in corso...")
        
        conf_res, str_sim, sem_sim, beh_sim, total_score = calculate_model_similarity(
            model_content_as_is, model_content_to_be
        )
        
        st.markdown("##### Conformance e Struttura")
        df_conf = pd.DataFrame(conf_res.items(), columns=['Metriche', 'Risultato']).set_index('Metriche')
        st.table(df_conf)

        st.markdown("##### Similarità Dettagliata")
        data_similarity = {
            'Metriche': ['Semantic similarity', 'Structural similarity', 'Behavioral similarity'],
            'Punteggio': [f"{sem_sim:.2f}", f"{str_sim:.2f}", f"{beh_sim:.2f}"]
        }
        df_similarity = pd.DataFrame(data_similarity).set_index('Metriche')
        st.table(df_similarity)
        
        st.markdown("##### Punteggio Globale")
        st.markdown(f"**Total Score:** **<span style='font-size: 24px; color: {'green' if total_score > 0.7 else 'orange'};'>{total_score * 100:.0f}%</span>**", unsafe_allow_html=True)
    else:
        st.info("Carica entrambi i modelli BPMN per visualizzare il confronto.")

st.markdown("---")
st.markdown("💡 *Questo approccio usa l'embedding di BPMN.js tramite Streamlit. I calcoli di similarità sono ancora placeholder e devono essere sostituiti con la logica PM4Py/LLM.*")