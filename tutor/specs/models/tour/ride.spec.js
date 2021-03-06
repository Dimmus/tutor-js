import { bootstrapCoursesList } from '../../courses-test-data';
import { times } from 'lodash';
import Tour from '../../../src/models/tour';
import TourContext from '../../../src/models/tour/context';
import TourRide from '../../../src/models/tour/ride';
import TourRegion from '../../../src/models/tour/region';

describe('Tour View Model', () => {
  let context;
  let region;
  let ride;
  beforeEach(() => {
    bootstrapCoursesList();
    context = new TourContext({ isEnabled: true });
    region = new TourRegion({ id: 'foo', courseId: '1', tour_ids: ['teacher-calendar'] });
    context.openRegion(region);
    ride = context.tourRide;
  });

  it('calculates props for joyride', () => {
    expect(ride.joyrideProps).toMatchObject({
      tourId: 'teacher-calendar',
    });
    expect(ride.joyrideProps.steps).toHaveLength(1);
    expect(ride.joyrideProps.steps[0]).toMatchObject({
      title: 'Your Openstax Tutor beta course dashboard',
      selector: '[data-tour-region-id="foo"]',
      position: 'center',
    });
  });

  it ('calculates if steps should show progress', () => {
    // no anchors
    expect(ride.joyrideProps.showStepsProgress).toBe(false);
    ride.tour.steps.forEach((s) => {
      if (s.anchor_id){
        context.addAnchor(s.anchor_id, {});
      }
    });
    expect(ride.joyrideProps.showStepsProgress).toBe(true);
  });

});
