import { Routes } from '@angular/router';
import { HomeComponent } from './_components/home/home.component';
import { CommanderDetailComponent } from './_components/commander-detail/commander-detail.component';

export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
    title: 'Randomize Commander - Home'
  },
  {
    path: 'commander',
    component: CommanderDetailComponent,
    title: 'Commander Details'
  },
  {
    path: '**',
    redirectTo: ''
  }
];