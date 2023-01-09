import { withPluginApi } from "discourse/lib/plugin-api";
import { htmlSafe } from "@ember/template";
import I18n from "I18n";

const PLUGIN_ID = "disorder";

export default {
  name: "disorder-composer-setup",
  initialize(container) {
    withPluginApi("1.5.0", (api) => {
      api.modifyClass("model:composer", {
        pluginId: PLUGIN_ID,
        disorderWarned: true,
      });

      const dialog = container.lookup("service:dialog");
      const siteSettings = container.lookup("service:site-settings");

      api.addComposerSaveErrorCallback((error) => {
        if (error.match(/Disorder detected/)) {
          // TODO: this is a hack
          let composerPreviewContents = document.querySelector(
            ".topic-post.staged.current-user-post .cooked"
          ).innerHTML;

          let modalMarkup = `
            <h2 class="disorder-modal-before-post">
              ${I18n.t("disorder.modal.title")}
            </h2>
            <p>
              ${I18n.t("disorder.modal.before_quote")}
            </p>
            <aside class="quote disorder-content-preview">
            <div class="title" style="cursor: pointer;" data-has-quote-controls="true" dir="ltr">
              <img loading="lazy" alt="" src="${api
                .getCurrentUser()
                .avatar_template.replace(
                  "{size}",
                  "20"
                )}" class="avatar" style="aspect-ratio: 20 / 20;" width="20" height="20">
              ${api.getCurrentUser().username}:
            </div>
              <blockquote>${composerPreviewContents}</blockquote>
            </aside>
            <p>
              ${I18n.t("disorder.modal.after_quote_1")} 
              <a href="/tos">${I18n.t("conduct")}</a>.
            </p>
            <p>
              ${I18n.t("disorder.modal.after_quote_2")}
            </p>
            <p><b>${
              siteSettings.disorder_warn_posting_above_toxicity
                ? I18n.t("disorder.modal.action_line_warning")
                : I18n.t("disorder.modal.action_line_warning")
            }</b></p>
          `;
          dialog.alert({ message: htmlSafe(modalMarkup) });

          api.serializeOnCreate("disorder_warned", "disorderWarned");
          api.serializeOnUpdate("disorder_warned", "disorderWarned");
          api.serializeToTopic("disorder_warned", "disorderWarned");

          return true;
        }
      });
    });
  },
};
