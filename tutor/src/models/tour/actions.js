import { findModel } from 'mobx-decorated-models';

import './actions/open-user-menu';
import './actions/open-calendar-sidebar';
import './actions/reposition';
import './actions/display-tours-replay-icon';

// TourActions
// scripted bits of logic for tour transitions like
// “Open User Menu” or “Advance Teacher Calendar” that will mimic user action during a tour.
// actions have an id and are specified as the TourStep

export default {

  forIdentifier(id) {
    return findModel(`tour/action/${id}`);
  },

};
