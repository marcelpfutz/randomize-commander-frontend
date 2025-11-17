import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { CommanderService } from './_services/commander.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('Randomize Commander');
  commanderInfo: any;

  constructor(
    private commanderService: CommanderService
  ) {}

  ngOnInit() {
    this.commanderService.getCommanders().subscribe((data) => {
      console.log('Commanders data:', data);
      this.commanderInfo = data;
    });
  }


}
