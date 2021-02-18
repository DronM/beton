-- Table: public.session_vals

-- DROP TABLE public.session_vals;

CREATE TABLE public.session_vals
(
    id character(36) COLLATE pg_catalog."default" NOT NULL,
    accessed_time timestamp with time zone DEFAULT now(),
    create_time timestamp with time zone DEFAULT now(),
    val bytea,
    CONSTRAINT session_vals_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.session_vals
    OWNER to beton;

-- Trigger: session_vals_trigger_after

-- DROP TRIGGER session_vals_trigger_after ON public.session_vals;

CREATE TRIGGER session_vals_trigger_after
    AFTER DELETE
    ON public.session_vals
    FOR EACH ROW
    EXECUTE PROCEDURE public.session_vals_process();
