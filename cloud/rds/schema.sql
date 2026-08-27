CREATE TABLE documents (
    id BIGSERIAL PRIMARY KEY,

    bucket VARCHAR(63) NOT NULL,
    object_key TEXT NOT NULL,

    event_type VARCHAR(100) NOT NULL,
    event_time TIMESTAMPTZ NOT NULL,

    etag VARCHAR(128),
    size_bytes BIGINT,

    status VARCHAR(32) NOT NULL DEFAULT 'received',

    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,

    error_message TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_documents_status
    ON documents(status);

CREATE INDEX idx_documents_object_key
    ON documents(object_key);

CREATE INDEX idx_documents_uploaded_at
    ON documents(uploaded_at);
