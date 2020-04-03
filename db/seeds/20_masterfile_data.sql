-- ADDRESS TYPES
INSERT INTO public.address_types(address_type) VALUES ('Delivery Address') ON CONFLICT DO NOTHING;

-- CONTACT METHOD TYPES
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Tel') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Fax') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Cell') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_method_types(contact_method_type) VALUES ('Email') ON CONFLICT DO NOTHING;

-- ROLES
INSERT INTO roles (name) VALUES ('IMPLEMENTATION_OWNER') ON CONFLICT DO NOTHING;
