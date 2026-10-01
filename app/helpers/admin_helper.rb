module AdminHelper
  # Traduce el valor de un enum: enum_label(Hall, :hall_type, "imax") => "IMAX"
  def enum_label(model_class, attribute, value)
    return "—" if value.blank?

    t("enums.#{model_class.model_name.i18n_key}.#{attribute}.#{value}", default: value.to_s.humanize)
  end

  # Opciones para un select de enum, con etiquetas traducidas.
  def enum_options(model_class, attribute)
    model_class.public_send(attribute.to_s.pluralize).keys.map do |value|
      [ enum_label(model_class, attribute, value), value ]
    end
  end

  def money(amount)
    number_to_currency(amount, unit: "$", separator: ",", delimiter: ".", precision: 2)
  end

  def date_time(value)
    value ? l(value, format: "%d/%m/%Y %H:%M") : "—"
  end

  def status_badge(order)
    tag.span(enum_label(Order, :status, order.status), class: "badge #{order.status}")
  end

  def nav_link(label, path, exact: false)
    active = exact ? request.path == path : request.path.start_with?(path)
    link_to label, path, class: ("active" if active)
  end

  def delete_button(record_path, label: "Eliminar")
    button_to label, record_path, method: :delete, class: "btn danger",
              form: { data: { turbo_confirm: "¿Seguro que querés eliminarlo?" } }
  end

  def form_errors(record)
    return if record.errors.empty?

    tag.div(class: "errors") do
      tag.strong("No se pudo guardar:") + tag.ul { safe_join(record.errors.full_messages.map { |m| tag.li(m) }) }
    end
  end
end
