# POSE — AI-Powered Privacy Policy Intelligence

**From legal text to a personalized Privacy Snapshot**

POSE is a prototype AI assistant designed to make privacy notices easier to
understand before users give consent.

The project was developed for a university AI competition around a simple
problem:

> People routinely accept privacy notices without understanding what data are
> collected, why they are processed, how long they are retained, or who may
> receive them.

POSE uses a Large Language Model to transform long privacy-policy text into a
structured, user-facing summary and then adapts the result to one of three
privacy-preference profiles.

---

## 1. Problem

Privacy policies are often:

- long;
- legally dense;
- difficult to compare;
- ignored at the point of consent.

Yet the information users care about is usually concrete:

```text
What data are collected?
Why are they processed?
How long are they retained?
Are they shared with third parties?
Which rights are explicitly stated?
Which practices deserve closer attention?
```

POSE aims to reduce the gap between formal disclosure and actual user
understanding.

---

## 2. What the Prototype Actually Implements

The implemented prototype is a **Python + Gradio application**.

The user:

1. pastes the text of a privacy policy;
2. selects a privacy profile;
3. sends the policy to a Gemini model;
4. receives a structured analysis;
5. sees a compact personalized Privacy Snapshot.

The current prototype is a text-analysis demo rather than a deployed browser
extension.

The browser-extension workflow shown in the project presentation represents
the **product architecture / next deployment layer**, not functionality already
implemented in the notebook.

---

## 3. Structured LLM Extraction

Instead of asking the LLM for an unrestricted summary, POSE constrains the
output through a typed Pydantic schema.

For every identified data practice, the model extracts:

```text
data_type
purpose[]
retention
mandatory_or_optional
shared_with[]
evidence[]
```

At document level, it also extracts:

```text
company_or_service
data_practices[]
user_rights[]
attention_points[]
simple_summary
```

This design makes the output easier to validate, display and process
programmatically than free-form text.

---

## 4. Evidence-Grounded Prompting

The prompt explicitly instructs the model to:

- use only information stated in the supplied policy;
- avoid inventing missing information;
- return `"Not specified"` when retention or mandatory status is absent;
- distinguish privacy rights from cookie-banner interface actions;
- avoid claiming that a practice is illegal;
- surface potentially sensitive or unclear practices instead;
- include short evidence excerpts supporting extracted practices.

The goal is not legal adjudication.

POSE is designed as an **information-extraction and user-awareness tool**, not
a GDPR compliance checker.

---

## 5. Personalized Privacy Profiles

The prototype supports three profiles:

```text
🔒 Minimal
⚖️ Balanced
✨ Convenience
```

Each profile assigns different penalty weights to practices such as:

- advertising / marketing;
- profiling;
- analytics;
- third-party sharing;
- geolocation;
- biometric data;
- unspecified retention.

The same privacy policy can therefore produce a different fit score depending
on the user's stated preferences.

---

## 6. Privacy Fit Score

After structured extraction, a deterministic rule layer evaluates the detected
practices against the selected profile.

Conceptually:

```text
LLM extraction
      ↓
structured privacy practices
      ↓
profile-specific rule engine
      ↓
Privacy Fit score + reasons
```

The score starts from:

```text
100
```

and subtracts profile-dependent penalties for relevant practices.

It is bounded below at zero.

The interface then maps the score to a qualitative label:

```text
75–100  → Good match
50–74   → Some attention needed
0–49    → Low privacy match
```

### Important interpretation

The Privacy Fit score is:

- a **preference-fit heuristic**;
- not a legal score;
- not a GDPR-compliance score;
- not a calibrated privacy-risk probability.

Its purpose is to help users identify which parts of a policy may matter most
to them.

---

## 7. User-Facing Privacy Snapshot

The Gradio interface compresses the structured analysis into a compact card
showing:

- service / company;
- Privacy Fit score;
- data collected;
- third-party sharing;
- retention information;
- one main attention point;
- explicitly stated user rights.

The design intentionally limits the number of visible items so the output
remains readable at the point of consent.

---

## 8. Prototype Pipeline

```text
Privacy-policy text
        ↓
Gemini API
        ↓
Structured JSON constrained by Pydantic
        ↓
Validation into PrivacyAnalysis objects
        ↓
Profile-specific scoring rules
        ↓
Compact HTML Privacy Snapshot
        ↓
Gradio interface
```

This hybrid architecture separates two responsibilities:

### LLM layer

Used for:

- legal-text interpretation;
- structured information extraction;
- concise summarization.

### Deterministic layer

Used for:

- preference scoring;
- warning generation;
- output formatting;
- profile comparison.

This avoids delegating the entire product decision logic to the generative
model.

---

## 9. Product Architecture Vision

The presentation extends the prototype into a browser-based consent workflow.

The envisioned architecture is:

```text
visited website
      ↓
browser extension
      ↓
privacy-policy acquisition
      ↓
backend analysis service
      ↓
cached result if already analysed
      ↓
LLM analysis if needed
      ↓
personalized Privacy Snapshot
      ↓
consent decision support
```

A cache / memory layer is proposed so that previously analysed documents do not
need to trigger a new LLM request every time.

This architecture was conceptual at competition stage; the notebook implements
the analysis and personalization core.

---

## 10. From Web Privacy to Smart-City Data Awareness

The project also explores a broader product direction: applying the same
transparency layer beyond websites.

Examples from the presentation include:

- public Wi-Fi;
- airports and stations;
- shared mobility;
- bike / e-bike / scooter services;
- ride-hailing and urban digital services.

These environments may process information such as:

- device identifiers;
- IP and access data;
- connection duration;
- geolocation;
- route history;
- payment information;
- device characteristics.

The underlying idea remains the same:

> surface what is being collected and why **before** the user proceeds.

---

## 11. Technology Stack

**Language:** Python  
**LLM:** Gemini API  
**Structured outputs:** Pydantic  
**Interface:** Gradio  
**Output rendering:** HTML / CSS  
**Architecture:** LLM extraction + deterministic personalization layer

---

## 12. Methodological Strengths

The prototype demonstrates:

- schema-constrained LLM output;
- structured extraction from unstructured legal text;
- evidence-aware prompting;
- guardrails against unsupported legal claims;
- deterministic post-processing after generation;
- user-preference modelling;
- human-readable AI output;
- rapid prototyping of an end-user GenAI application.

---

## 13. Limitations

POSE is an early prototype.

Important limitations include:

- privacy policies are pasted manually in the current demo;
- no browser extension is implemented in the notebook;
- no automatic privacy-policy crawler is implemented in the notebook;
- LLM extractions may still contain errors or omissions;
- evidence extraction does not constitute formal legal verification;
- the Privacy Fit score is heuristic;
- penalty accumulation can depend on how the LLM segments data practices;
- score weights are manually defined rather than empirically calibrated;
- there is no benchmark dataset or expert-labelled evaluation set;
- there is no legal-compliance certification;
- there is no production authentication, persistence or API infrastructure.

These gaps define the difference between the competition prototype and a
production-ready privacy product.

---

## 14. Production-Oriented Next Steps

A stronger production version could add:

1. automatic discovery and extraction of privacy-policy text;
2. policy hashing and caching;
3. URL-level browser-extension integration;
4. structured evaluation against expert-labelled privacy policies;
5. extraction-confidence and uncertainty indicators;
6. citation links from each extracted claim back to the source paragraph;
7. version tracking when a privacy policy changes;
8. configurable user-preference weights;
9. multilingual policy processing;
10. privacy-preserving backend architecture and telemetry governance.

---

## Repository Structure

```text
pose-ai-privacy-assistant/
├── README.md
├── notebooks/
│   ├── README.md
│   └── 01_pose_privacy_analysis.ipynb
├── docs/
│   └── architecture.md
└── results/
    ├── README.md
    ├── prototype_interface.png
    └── product_architecture.png
```

---

## Key Takeaway

POSE is not a legal oracle.

Its value lies in translating a difficult document into a **structured,
personalized and inspectable decision aid**.

The project demonstrates a practical GenAI design pattern:

> **use the LLM for language understanding, then use deterministic logic for
> product behaviour.**

That separation makes the prototype more transparent, controllable and
extensible than a purely free-form chatbot.
