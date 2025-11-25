# ProMatch Phase I — Replication Package

## Purpose
This repository enables replication of the multilingual BERT-based BPMN similarity experiment.

## Files
/src/bert_similarity.py
/bpmn_models/Cologne.bpmn
/bpmn_models/Frankfurt.bpmn
requirements.txt

perl
Copia codice

## Installation
bash
pip install -r requirements.txt
Run Experiment
bash
Copia codice
python src/bert_similarity.py
Output
Global similarity score

Matched tasks, lanes, gateways with cosine similarity values

Notes
Deterministic execution (no randomness)

GPU not required

# ProMatch Phase II — Replication Package

This repository reproduces the BPMN comparison experiment using LLM prompting.

## Files
/src/prompt_eval.py
/src/promatch_prompt.txt
/bpmn_models/Cologne.bpmn
/bpmn_models/Frankfurt.bpmn

markdown
Copia codice

## Requirements
- Ollama 0.2+
- llama3 model installed
- Python 3.10+

## Setup
```bash
brew install ollama
ollama pull llama3
Run Experiment
bash
Copia codice
python src/prompt_eval.py


