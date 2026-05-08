#include "include/secure_application/secure_application_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define SECURE_APPLICATION_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), secure_application_plugin_get_type(), \
                              SecureApplicationPlugin))

struct _SecureApplicationPlugin {
  GObject parent_instance;
  FlMethodChannel* channel;
  GtkWindow* window;
  gulong window_state_handler_id;
};

G_DEFINE_TYPE(SecureApplicationPlugin, secure_application_plugin,
              g_object_get_type())

// Mirrors Windows: respond Success() to every method call. The actual lock /
// blur UI is rendered Dart-side by SecureGate, so the native plugin only needs
// to acknowledge channel calls and invoke "lock" on system events.
static void secure_application_plugin_handle_method_call(
    SecureApplicationPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar* version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
  fl_method_call_respond(method_call, response, nullptr);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  SecureApplicationPlugin* plugin = SECURE_APPLICATION_PLUGIN(user_data);
  secure_application_plugin_handle_method_call(plugin, method_call);
}

// Mirrors the Windows SC_MINIMIZE hook: when the toplevel window is iconified,
// invoke the Dart-side "lock" handler so the SecureGate overlay engages before
// the user-restored window is repainted.
static gboolean window_state_event_cb(GtkWidget* widget,
                                      GdkEventWindowState* event,
                                      gpointer user_data) {
  SecureApplicationPlugin* self = SECURE_APPLICATION_PLUGIN(user_data);
  if ((event->changed_mask & GDK_WINDOW_STATE_ICONIFIED) &&
      (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED)) {
    fl_method_channel_invoke_method(self->channel, "lock", nullptr, nullptr,
                                    nullptr, nullptr);
  }
  return FALSE;
}

static void secure_application_plugin_dispose(GObject* object) {
  SecureApplicationPlugin* self = SECURE_APPLICATION_PLUGIN(object);
  if (self->window != nullptr && self->window_state_handler_id != 0) {
    g_signal_handler_disconnect(self->window, self->window_state_handler_id);
    self->window_state_handler_id = 0;
    self->window = nullptr;
  }
  g_clear_object(&self->channel);
  G_OBJECT_CLASS(secure_application_plugin_parent_class)->dispose(object);
}

static void secure_application_plugin_class_init(
    SecureApplicationPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = secure_application_plugin_dispose;
}

static void secure_application_plugin_init(SecureApplicationPlugin* self) {}

void secure_application_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  SecureApplicationPlugin* plugin = SECURE_APPLICATION_PLUGIN(
      g_object_new(secure_application_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "secure_application", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  FlView* view = fl_plugin_registrar_get_view(registrar);
  if (view != nullptr) {
    GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));
    if (GTK_IS_WINDOW(toplevel)) {
      plugin->window = GTK_WINDOW(toplevel);
      plugin->window_state_handler_id =
          g_signal_connect(toplevel, "window-state-event",
                           G_CALLBACK(window_state_event_cb), plugin);
    }
  }

  g_object_unref(plugin);
}
